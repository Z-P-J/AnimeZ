import { DownloadUtils } from '../../download/DownloadUtils';
import Logger from '../../utils/Logger';
import M3u8, { M3u8Segment } from './M3U8';
import HttpUtils from '../../utils/HttpUtils';
import fs from '@ohos.file.fs';

// base hls tag:
const PLAYLIST_HEADER = "#EXTM3U"; // must
const TAG_PREFIX = "#EXT"; // must
const TAG_VERSION = "#EXT-X-VERSION"; // must
const TAG_MEDIA_SEQUENCE = "#EXT-X-MEDIA-SEQUENCE"; // must
const TAG_TARGET_DURATION = "#EXT-X-TARGETDURATION"; // must
const TAG_MEDIA_DURATION = "#EXTINF"; // must
const TAG_DISCONTINUITY = "#EXT-X-DISCONTINUITY"; // Optional
const TAG_ENDLIST = "#EXT-X-ENDLIST"; // It is not live if hls has '#EXT-X-ENDLIST' tag; Or it
// is.
const TAG_KEY = "#EXT-X-KEY"; // Optional
const TAG_INIT_SEGMENT = "#EXT-X-MAP";

const TAG_STREAM_INF = "#EXT-X-STREAM-INF"; // Multiple m3u8 stream, we usually fetch the first.

const REGEX_TARGET_DURATION = new RegExp(TAG_TARGET_DURATION + ":(\\d+)\\b");
const REGEX_MEDIA_DURATION = new RegExp(TAG_MEDIA_DURATION + ":([\\d\\.]+)\\b");
const REGEX_VERSION = new RegExp(TAG_VERSION + ":(\\d+)\\b");
const REGEX_MEDIA_SEQUENCE = new RegExp(TAG_MEDIA_SEQUENCE + ":(\\d+)\\b");
const REGEX_BANDWIDTH = new RegExp("BANDWIDTH=(\\d+)\\b");
const REGEX_RESOLUTION = new RegExp("RESOLUTION=(\\d+x\\d+)");

const METHOD_NONE = "NONE";
const METHOD_AES_128 = "AES-128";
const METHOD_SAMPLE_AES = "SAMPLE-AES";
// Replaced by METHOD_SAMPLE_AES_CTR. Keep for backward compatibility.
const METHOD_SAMPLE_AES_CENC = "SAMPLE-AES-CENC";
const METHOD_SAMPLE_AES_CTR = "SAMPLE-AES-CTR";
const REGEX_METHOD = new RegExp("METHOD=(" + METHOD_NONE + "|" + METHOD_AES_128 + "|" +
METHOD_SAMPLE_AES + "|" + METHOD_SAMPLE_AES_CENC + "|" + METHOD_SAMPLE_AES_CTR + ")" + "\\s*(,|$)");
const REGEX_KEYFORMAT = new RegExp("KEYFORMAT=\"(.+?)\"");
const REGEX_URI = new RegExp("URI=\"(.+?)\"");
const REGEX_IV = new RegExp("IV=([^,.*]+)");
const KEYFORMAT_IDENTITY = "identity";
const REGEX_ATTR_BYTERANGE = new RegExp("BYTERANGE=\"(\\d+(?:@\\d+)?)\\b\"");

/**
 * 解析m3u8和保存m3u8
 * 参考
 */
export default class M3U8Utils {

    /**
     * 从链接中解析m3u8信息
     * @param parentUrl 父链接
     * @param videoUrl m3u8视频链接
     * @param content m3u8内容
     */
    static async parse(parentUrl: string, videoUrl: string, content?: string): Promise<M3u8> {
        //        let content = await HttpUtils.getString(videoUrl)
        Logger.e(this, 'parse parentUrl=' + parentUrl + ' videoUrl=' + videoUrl)
        if (!content) {
            content = await HttpUtils.getString(videoUrl)
        }
        Logger.e(this, 'parse content=' + content)
        let start = 0
        let end = content.indexOf('\n', start)
        let m3u8 = new M3u8()
        m3u8.url = videoUrl

        let targetDuration = 0;
        let version = 0;
        let sequence = 0;
        let hasDiscontinuity = false;
        let hasEndList = false;
        let hasMasterList = false;
        let hasKey = false;
        let hasInitSegment = false;
        let method = null;
        let keyIv = null;
        let keyUrl = null;
        let initSegmentUri = null;
        let segmentByteRange = null;
        let segDuration = 0;
        let segIndex = 0;

        while (end > start) {
            let line = content.substring(start, end).trim()
            Logger.e(this, 'parse line=' + line)
            if (line.startsWith(TAG_PREFIX)) {
                if (line.startsWith(TAG_MEDIA_DURATION)) {
                    let ret = this.parseStringAttr(line, REGEX_MEDIA_DURATION)
                    Logger.e(this, 'ret=' + ret)
                    if (ret) {
                        segDuration = parseFloat(ret)
                    }
                } else if (line.startsWith(TAG_TARGET_DURATION)) {
                    let ret = this.parseStringAttr(line, REGEX_TARGET_DURATION)
                    if (ret) {
                        targetDuration = parseInt(ret)
                    }
                } else if (line.startsWith(TAG_VERSION)) {
                    let ret = this.parseStringAttr(line, REGEX_VERSION)
                    if (ret) {
                        version = parseInt(ret)
                    }
                } else if (line.startsWith(TAG_MEDIA_SEQUENCE)) {
                    let ret = this.parseStringAttr(line, REGEX_MEDIA_SEQUENCE)
                    if (ret) {
                        sequence = parseInt(ret)
                    }
                } else if (line.startsWith(TAG_STREAM_INF)) {
                    hasMasterList = true;
                } else if (line.startsWith(TAG_DISCONTINUITY)) {
                    hasDiscontinuity = true;
                } else if (line.startsWith(TAG_ENDLIST)) {
                    hasEndList = true;
                } else if (line.startsWith(TAG_KEY)) {
                    hasKey = true
                    method = this.parseOptionalStringAttr(line, REGEX_METHOD)
                    let keyFormat = this.parseOptionalStringAttr(line, REGEX_KEYFORMAT);
                    if (method != METHOD_NONE) {
                        keyIv = this.parseOptionalStringAttr(line, REGEX_IV)
                        if (keyFormat || keyFormat == KEYFORMAT_IDENTITY) {
                            if (method == METHOD_AES_128) {
                                // The segment is fully encrypted using an identity key.
                                let tempKeyUri = this.parseStringAttr(line, REGEX_URI);
                                if (tempKeyUri != null) {
                                    keyUrl = this.getM3U8MasterUrl(videoUrl, tempKeyUri);
                                }
                            } else {
                                // Do nothing. Samples are encrypted using an identity key,
                                // but this is not supported. Hopefully, a traditional DRM
                                // alternative is also provided.
                            }
                        } else {
                            // do nothing
                        }
                    }
                } else if (line.startsWith(TAG_INIT_SEGMENT)) {
                    let tempInitSegmentUri = this.parseStringAttr(line, REGEX_URI);
                    if (tempInitSegmentUri) {
                        hasInitSegment = true;
                        initSegmentUri = this.getM3U8MasterUrl(videoUrl, tempInitSegmentUri);
                        segmentByteRange = this.parseOptionalStringAttr(line, REGEX_ATTR_BYTERANGE);
                    }
                }
                start = end + 1
                end = content.indexOf('\n', start)
                if (end < 0) {
                    end = content.length
                }
                Logger.e(this, 'parse start=' + start + ' end=' + end + ' len=' + content.length)
                continue
            }

            Logger.e(this, 'hasMasterList=' + hasMasterList)
            // It has '#EXT-X-STREAM-INF' tag;
            if (hasMasterList) {
                let tempUrl = this.getM3U8MasterUrl(videoUrl, line);
                Logger.e(this, 'tempUrl=' + tempUrl)
                return this.parse(parentUrl, tempUrl);
            }

            Logger.e(this, 'segDuration=' + segDuration)
            if (Math.abs(segDuration) < 0.001) {
                start = end + 1
                end = content.indexOf('\n', start)
                continue;
            }

            let seg = new M3u8Segment();
            seg.parentUrl = parentUrl;
            let tempUrl = this.getM3U8MasterUrl(videoUrl, line);
            Logger.e(this, 'seg tempUrl=' + tempUrl)
            seg.url = tempUrl;
            let name = DownloadUtils.guessFileName(tempUrl)
            seg.name = name ? name : (segIndex + '.ts')
            seg.segIndex = segIndex;
            seg.duration = segDuration;
            seg.hasDiscontinuity = hasDiscontinuity;
            seg.hasKey = hasKey;
            if (hasKey) {
                seg.method = method;
                seg.keyIv = keyIv;
                seg.keyUrl = keyUrl;
                let name = DownloadUtils.guessFileName(tempUrl)
                seg.keyName = name ? name : (segIndex + '.key')
            }
            if (hasInitSegment) {
                seg.hasInitSegment = true
                seg.initSegmentUri = initSegmentUri
                seg.segmentByteRange = segmentByteRange
            }
            Logger.e(this, 'push')
            m3u8.segmentList.push(seg);
            Logger.e(this, 'push finished')
            segIndex++;
            segDuration = 0;
            hasDiscontinuity = false;
            hasKey = false;
            hasInitSegment = false;
            method = null;
            keyUrl = null;
            keyIv = null;
            initSegmentUri = null;
            segmentByteRange = null;

            start = end + 1
            Logger.e(this, 'start=' + start)
            end = content.indexOf('\n', start)
            Logger.e(this, 'start=' + start + ' end=' + end)
        }
        m3u8.duration = targetDuration;
        m3u8.version = version;
        m3u8.sequence = sequence;
        m3u8.isLive = !hasEndList;
        return m3u8;
    }

    /**
     * 将M3u8转换为字符串，并保存至本地
     * @param m3u8
     * @param path
     */
    static async saveM3U8OriginInfo(m3u8: M3u8, path: string): Promise<number> {

        let content = PLAYLIST_HEADER + '\n' + TAG_VERSION + ":" + m3u8.version + "\n"
        content += TAG_MEDIA_SEQUENCE + ":" + m3u8.sequence + "\n"
        content += TAG_TARGET_DURATION + ":" + m3u8.duration + "\n"

        for (let seg of m3u8.segmentList) {
            if (seg.hasInitSegment) {
                let initSegmentInfo;
                if (seg.segmentByteRange) {
                    initSegmentInfo = "URI=\"" + seg.initSegmentUri + "\"" + ",BYTERANGE=\"" + seg.segmentByteRange + "\"";
                } else {
                    initSegmentInfo = "URI=\"" + seg.initSegmentUri + "\"";
                }
                content += TAG_INIT_SEGMENT + ":" + initSegmentInfo + "\n"
            }

            if (seg.hasKey && seg.method) {
                let key = "METHOD=" + seg.method;
                if (seg.keyUrl) {
                    key += ",URI=\"" + seg.keyUrl + "\"";
                    if (seg.keyIv) {
                        key += ",IV=" + seg.keyIv;
                    }
                }
                content += TAG_KEY + ":" + key + "\n"
            }
            if (seg.hasDiscontinuity) {
                content += TAG_DISCONTINUITY + "\n"
            }
            content += TAG_MEDIA_DURATION + ":" + seg.duration + ",\n" + seg.url + '\n'
        }

        content += TAG_ENDLIST

        Logger.e(this, 'saveM3U8OriginInfo content=' + content)

        let file = await fs.open(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        return fs.write(file.fd, content, {encoding: 'utf-8'})
    }

    /**
     * 将M3u8中的分片地址和key地址转换为本地路径，转换为字符串并保存至本地。保存的文件用于本地播放
     * @param m3u8
     * @param path
     */
    static async saveM3U8LocalInfo(m3u8: M3u8, path: string): Promise<number> {

        let content = PLAYLIST_HEADER + '\n' + TAG_VERSION + ":" + m3u8.version + "\n"
        content += TAG_MEDIA_SEQUENCE + ":" + m3u8.sequence + "\n"
        content += TAG_TARGET_DURATION + ":" + m3u8.duration + "\n"

        for (let seg of m3u8.segmentList) {
            if (seg.hasInitSegment) {
                let initSegmentInfo;
                if (seg.segmentByteRange) {
                    initSegmentInfo = "URI=\"" + seg.initSegmentUri + "\"" + ",BYTERANGE=\"" + seg.segmentByteRange + "\"";
                } else {
                    initSegmentInfo = "URI=\"" + seg.initSegmentUri + "\"";
                }
                content += TAG_INIT_SEGMENT + ":" + initSegmentInfo + "\n"
            }

            if (seg.hasKey && seg.method) {
                let key = "METHOD=" + seg.method;
                if (seg.keyName) {
                    key += ",URI=\"" + seg.keyName + "\"";
                    if (seg.keyIv) {
                        key += ",IV=" + seg.keyIv;
                    }
                }
                content += TAG_KEY + ":" + key + "\n"
            }
            if (seg.hasDiscontinuity) {
                content += TAG_DISCONTINUITY + "\n"
            }
            content += TAG_MEDIA_DURATION + ":" + seg.duration + ",\n" + seg.name + '\n'
        }

        content += TAG_ENDLIST

        Logger.e(this, 'saveM3U8OriginInfo content=' + content)

        let file = await fs.open(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        return fs.write(file.fd, content, {encoding: 'utf-8'})
    }
    
    static parseStringAttr(line, re: RegExp): string {
        let match = re.exec(line)
        Logger.e(this, 'match=' + match + " len=" + match.length)
        if (match && match.length == 2) {
            return match[1]
        }
        return null
    }

    static parseOptionalStringAttr(line, re: RegExp): string {
        let match = re.exec(line)
        if (match) {
            return match[0]
        }
        return null
    }

    static getM3U8MasterUrl(videoUrl, line) {
        Logger.e(this, 'videoUrl=' + videoUrl + ' line=' + line)
        if (!videoUrl || !line) {
            return "";
        }
        if (videoUrl.startsWith("file://") || videoUrl.startsWith("/")) {
            return videoUrl;
        }
        let baseUriPath = this.getBaseUrl(videoUrl);
        Logger.e(this, 'baseUriPath=' + baseUriPath)
        let hostUrl = this.getHostUrl(videoUrl);
        Logger.e(this, 'hostUrl=' + hostUrl)

        if (line.startsWith("//")) {
            let tempUrl = this.getSchema(videoUrl) + ":" + line;
            return tempUrl;
        }

        if (line.startsWith("/")) {
            Logger.e(this, 'startsWith /')
            let pathStr = this.getPathStr(videoUrl);
            Logger.e(this, 'pathStr=' + pathStr)
            let longestCommonPrefixStr = this.getLongestCommonPrefixStr(pathStr, line);
            Logger.e(this, 'longestCommonPrefixStr=' + longestCommonPrefixStr)
            if (hostUrl.endsWith("/")) {
                hostUrl = hostUrl.substring(0, hostUrl.length - 1);
            }
            Logger.e(this, 'hostUrl=' + hostUrl)
            let tempUrl = hostUrl + longestCommonPrefixStr + line.substring(longestCommonPrefixStr.length);
            Logger.e(this, 'tempUrl=' + tempUrl)
            return tempUrl;
        }

        if (line.startsWith("http")) {
            return line;
        }

        return baseUriPath + line;
    }

    /**
     * 例如https://xvideo.d666111.com/xvideo/taohuadao56152307/index.m3u8
     * 我们希望得到https://xvideo.d666111.com/xvideo/taohuadao56152307/
     *
     * @param url
     * @return
     */
    static getBaseUrl(url: string) {
        let slashIndex = url.lastIndexOf("/");
        if (slashIndex != -1) {
            return url.substring(0, slashIndex + 1);
        }
        return url;
    }

    /**
     * 例如https://xvideo.d666111.com/xvideo/taohuadao56152307/index.m3u8
     * 我们希望得到https://xvideo.d666111.com/
     *
     * @param url
     * @return
     */
    static getHostUrl(url: string): string {

        let index = url.indexOf('//')
        if (index < 0) {
            return url.substring(0, url.indexOf('/') + 1)
        } else {
            return url.substring(0, url.indexOf('/', index + 2) + 1)
        }
    }

    static getPathStr(url: string) {
        let hostUrl = this.getHostUrl(url);
        if (hostUrl) {
            return url.substring(hostUrl.length - 1);
        }
        return url;
    }

    private static getSchema(url: string) {
        let index = url.indexOf("://");
        if (index != -1) {
            let result = url.substring(0, index);
            return result;
        }
        return "";
    }

    /**
     * 获取两个字符串的最长公共前缀
     * /xvideo/taohuadao56152307/500kb/hls/index.m3u8   与     /xvideo/taohuadao56152307/index.m3u8
     * <p>
     * /xvideo/taohuadao56152307/500kb/hls/jNd4fapZ.ts  与     /xvideo/taohuadao56152307/500kb/hls/index.m3u8
     *
     * @param str1
     * @param str2
     * @return
     */
    private  static getLongestCommonPrefixStr(str1: string, str2: string): string {
        if (str1 == str2) {
            return str1;
        }
        let j = 0;
        while (j < str1.length && j < str2.length) {
            if (str1[j] != str2[j]) {
                break;
            }
            j++;
        }
        return str1.substring(0, j);
    }
}