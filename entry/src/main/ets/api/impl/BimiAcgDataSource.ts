import { DramaList } from '../../entity/HomepageData';
import HomepageData from '../../entity/HomepageData';
import Logger from '../../utils/Logger';
import EpisodeInfo from '../../entity/EpisodeInfo';
import { CssSelector } from '../../utils/css/CssSelector';
import VideoInfo from '../../entity/VideoInfo';
import EpisodeList from '../../entity/EpisodeList';
import VideoDetailInfo from '../../entity/VideoDetailInfo';
import HttpUtils from '../../utils/HttpUtils';
import DataSource from '../DataSource';
import { Element, Document } from "domhandler"

const PREFIX_DATA = "var player_aaaa="
const BASE_URL = 'http://www.bimiacg4.net'

/**
 * TODO 该源部分视频链接无法解析到，暂时废弃
 */
export default class BimiAcgDataSource implements DataSource {
    getKey(): string {
        return 'key_bimi_acg'
    }

    async search(keyword: string, page: number): Promise<VideoInfo[]> {
        let url = "http://www.bimiacg4.net/vod/search/wd/" + encodeURIComponent(keyword) + "/page/" + page

        let doc = await HttpUtils.getHtml(url)
        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
        return this.parseVideoList(drama)
    }

    async getHomepageData(): Promise<HomepageData> {
        let url = BASE_URL
        let doc = await HttpUtils.getHtml(url)

        let bannerList = null
        let categoryList: DramaList[] = []
        let categorys = CssSelector.find(doc, 'body > section > div.area-drama')
        for (let drama of categorys) {
            let header = CssSelector.findFirst(drama, "div.area-header")

            if (bannerList == null) {
                bannerList = await this.parseVideoList(CssSelector.findFirst(drama, 'ul.drama-module'))
            } else {
                categoryList.push({
                    title: CssSelector.selectTextContent(header, "h2.title > b"),
                    moreUrl: BASE_URL + CssSelector.selectAttributeValue(header, 'a', 'href'),
                    videoList: await this.parseVideoList(CssSelector.findFirst(drama, 'ul.drama-module'))
                })
            }
        }
        return {
            bannerList: bannerList,
            categoryList: categoryList
        }
    }

    async getVideoList(page: number): Promise<VideoInfo[]> {
        let url = "http://www.bimiacg4.net/type/riman-" + page
        let doc = await HttpUtils.getHtml(url)
        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
        return this.parseVideoList(drama)
    }

    private async parseVideoList(drama): Promise<VideoInfo[]> {
        //        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
        Logger.e(this, 'parseHtml drama=' + drama)
        let elements = CssSelector.find(drama, 'li')
        Logger.e(this, 'parseHtml elements=' + elements)
        let videoList: VideoInfo[] = []

        // TODO 代码优化
        elements.forEach((el) => {
            Logger.e(this, "parseHtml el=" + el)
            let img = CssSelector.findFirst(el, 'img')
            let a = CssSelector.findFirst(el, "div.info > a")
            videoList.push({
                sourceKey: this.getKey(),
                url: "http://www.bimiacg4.net" + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.getAttributeValue(img, 'src'),
                title: CssSelector.textContent(a),
                episode: CssSelector.selectTextContent(el, "div.info > p > span.fl")
            })
        })
        return videoList
    }

    async getVideoDetailInfo(url: string): Promise<VideoDetailInfo> {
        let doc = await HttpUtils.getHtml(url);

        Logger.e(this, 'getVideoDetailInfo 1')
        let category = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(3) > a")
        Logger.e(this, 'getVideoDetailInfo 2 category=' + category)

        let test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(4)")
        Logger.e(this, 'getVideoDetailInfo 3 test=' + test)

        test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(5)")
        Logger.e(this, 'getVideoDetailInfo 4 test=' + test)

        test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(2)")
        Logger.e(this, 'getVideoDetailInfo 5 test=' + test)

        let info: VideoDetailInfo = {
            sourceKey: this.getKey(),
            title: CssSelector.selectTextContent(doc, "div.txt_intro_con > div > h1"),
            url: url,
            desc: CssSelector.selectTextContent(doc, "li.li_intro"),
            coverUrl: CssSelector.selectAttributeValue(doc, "div.poster_placeholder > div > img", 'src'),
            category: category == null ? null : CssSelector.textContent(category),
            director: CssSelector.selectTextContent(doc, "div.txt_intro_con > ul > li:nth-child(4)"),
            updateTime: CssSelector.selectTextContent(doc, "div.txt_intro_con > ul > li:nth-child(5)"),
            protagonist: CssSelector.selectTextContent(doc, "div.txt_intro_con > ul > li:nth-child(2)"),
            episodes: await this.getEpisodes(doc),
            recommends: await this.getRecommends(doc)
        }
        return info
    }

    async getEpisodes(doc: Document): Promise<EpisodeList[]> {

        let list: EpisodeList[] = []
        let elements = CssSelector.find(doc, "ul.player_list")
        let title = CssSelector.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > div > h1"))
        elements.forEach((el, i) => {
            let episodeList: EpisodeList = {
                title: "路线" + i,
                episodes: []
            }

            CssSelector.find(el, 'a').forEach((a) => {
                let info: EpisodeInfo = {
                    link: "http://www.bimiacg4.net" + CssSelector.getAttributeValue(a, 'href'),
                    title: CssSelector.textContent(a),
                    desc: title + ' ' + CssSelector.textContent(a)
                }
                Logger.e(this, 'getEpisodes info=' + JSON.stringify(info))
                episodeList.episodes.push(info)
            })

            Logger.e(this, 'getEpisodes episodeList=' + JSON.stringify(episodeList))
            list.push(episodeList)

        })

        return list
    }

    async getRecommends(doc: Document): Promise<VideoInfo[]> {
        let videoList: VideoInfo[] = []
        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
        let elements = CssSelector.find(drama, 'li')
        elements.forEach((el) => {
            let img = CssSelector.findFirst(el, 'img')
            let elInfo = CssSelector.findFirst(el, "div.info")
            let a = CssSelector.findFirst(elInfo, "a")
            videoList.push({
                sourceKey: this.getKey(),
                url: "http://www.bimiacg4.net" + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.getAttributeValue(img, 'src'),
                title: CssSelector.textContent(a),
                episode: CssSelector.selectTextContent(elInfo, "span.fl"),
                updateTime: CssSelector.selectTextContent(elInfo, 'em.fr')
            })
        })
        return videoList
    }

    async parseVideoUrl(link: string): Promise<string> {
        Logger.e(this, 'parseVideoUrl link=' + link)
        let doc = await HttpUtils.getHtml(link)
        let video = CssSelector.findFirst(doc, 'div#video')
        let scripts = CssSelector.find(video, 'script')

        for (let script of scripts) {
            let text = CssSelector.textContent(script)
            Logger.e(this, 'script text=' + text)
            if (text.startsWith(PREFIX_DATA)) {
                text = text.substring(PREFIX_DATA.length)
                Logger.e(this, 'substring script text=' + text)
                let obj = JSON.parse(text)
                let url: string = obj['url']
                Logger.e(this, 'parseVideoUrl url=' + url)

                let videoUrl
                if (url.startsWith('http')) {
                    doc = await HttpUtils.getHtml(url, {
                        referer: 'http://www.bimiacg4.net/'
                    })

                    let html = CssSelector.getInnerHTML(doc)
                    let start = 0
                    let end = html.indexOf('\n', start)
                    while (end >= 0) {
                        Logger.e(this, 'start=' + start + ' end=' + end + ' line=' + html.substring(start, end))
                        start = end + 1
                        end = html.indexOf('\n', start)
                    }

                    /**
                     * TODO 解密视频链接
                     var url = '8313539363130313037313338373431373D344946455D2A7D616D28762537373539393135363335393439383D3449455D2A7D616D28762734373634393537333D354A5943564D2A7D616D287624307D6F2F656469667D356079747D247E65647E6F636D25637E6F60737562762030343230313D3564716274796D696C6D2A7D616D2876223631303631363836313D337562796078754623636361673164373365683162616932333636366D346949756B4373756363614357514624433523653374403242352644323F29644C6C44384544707B473475636739637D35627574716E676963562E475F4E4B4E455D3E4945405954545E45494C434D2A7D616D287620525F434D3E494540595454455F4C434D2A7D616D28762E475F4E4B4E455D3B425F4754554E445E45494C434D2A7D616D287624307D6E2445353235203035313638363138303138503239313245353235244535323524305D4F5247424535323524453532352733324535323529757D616B4242352E65646C6F67444535323522455359584245353235273235273235283D2644555443352A256D616E656C696662433522323524307D6E24453520383031385032393132453524453524305D4F5247424535244535273332453529757D616B4032352E65646C6F674445352245535958424535223235244335256D616E656C6966624335247E656D6863616474716D3E6F696479637F607379646D247E65647E6F636D25637E6F607375627F34307D6E2731336938353362366139363D263567383D233262643D256432333D26683631603362633F2E636E2960716E657974736E2A626D21786D237F6F6E2E6F637275607D2A70776D276E696A6965626D29383134657F6C636F2F2A33707474786', err = '',dmId=0,vt='2';
                     // TODO 真实链接
                     真实链接：https://cloud189-beijing-gpz-person.oos-hq-bj.ctyunapi.cn/3bc0a68f-324e-4bb3-87e6-691f2c589c17.mp4?response-content-disposition=attachment%3Bfilename%3D%22%5BHYSUB%5DGolden%20Kamuy%5B37%5D%5BGB_MP4%5D%5B1920X1080%5D.mp4%22%3Bfilename*%3DUTF-8%27%27%255BHYSUB%255DGolden%2BKamuy%255B37%255D%255BGB_MP4%255D%255B1920X1080%255D.mp4&x-amz-CLIENTNETWORK=UNKNOWN&x-amz-CLOUDTYPEIN=CORP&x-amz-CLIENTTYPEIN=UNKNOWN&Signature=si7cet7KptEH4LlDi/24F%2B0Ds5c%3D&AWSAccessKeyId=f66329aba8ec74a7accc&Expires=1686160162&x-amz-limitrate=102400&response-content-type=video/mp4&x-amz-FSIZE=375946747&x-amz-UID=894953651995775&x-amz-UFID=71478317010169518
                     */

                    throw new Error('link not support! url: ' + url)
                } else {
                    // 解析视频真实链接
                    url = "http://www.bimiacg4.net/static/danmu/pic.php?url=" + url + '&myurl=' + link;
                    Logger.e(this, 'parseVideoUrl url=' + url)

                    doc = await HttpUtils.getHtml(url)
                    let src = CssSelector.selectAttributeValue(doc, 'source', 'src')
                    Logger.e(this, 'parseVideoUrl src=' + src)

                    if (src.startsWith('./')) {
                        videoUrl = src.replace("./", "http://www.bimiacg4.net/static/danmu/")
                    } else {
                        videoUrl = src
                    }
                    Logger.e(this, 'parseVideoUrl videoUrl=' + videoUrl)
                }
                return videoUrl
            }
        }
        return null;
    }
}