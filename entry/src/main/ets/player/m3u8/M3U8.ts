
export class M3u8Segment {

    /**
     * 分片的上级M3U8的url
     */
    parentUrl: string

    /**
     * 分片下载地址
     */
    url: string

    /**
     * 分片名称
     */
    name: string

    /**
     * 分片时长
     */
    duration: number

    /**
     * 分片索引位置，起始索引为0
     */
    segIndex: number

    /**
     * 分片文件大小
     */
    segSize: number

    /**
     * 分片文件的网络请求的content-length
     */
    contentLength: number

    /**
     * 当前分片文件前是否有Discontinuity
     */
    hasDiscontinuity: boolean

    /**
     * 分片文件是否加密
     */
    hasKey: boolean

    /**
     * 分片加密方法
     */
    method: string

    /**
     * 分片文件的密钥地址
     */
    keyUrl: string

    /**
     * 密钥名称
     */
    keyName: string

    /**
     * 密钥IV
     */
    keyIv: string

    /**
     * 重试请求次数
     */
    retryCount: number

    /**
     * 分片前是否有#EXT-X-MAP
     */
    hasInitSegment: boolean

    /**
     * MAP的url
     */
    initSegmentUri: string

    /**
     * MAP的range
     */
    segmentByteRange: string

}

export default class M3u8 {



    /**
     * m3u8播放地址
     */
    url: string

    /**
     * 指定的duration
     */
    duration: number

    /**
     * 序列起始值
     */
    sequence: number

    /**
     * 版本号
     */
    version: number

    /**
     * 是否是直播
     */
    isLive: boolean

    /**
     * 分片列表
     */
    readonly segmentList: M3u8Segment[] = []


}



