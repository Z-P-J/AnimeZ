import Logger from '../../utils/Logger';
import EpisodeInfo from '../../entity/EpisodeInfo';
import { CssSelector } from '../../utils/CssSelector';
import VideoInfo from '../../entity/VideoInfo';
import EpisodeList from '../../entity/EpisodeList';
import VideoDetailInfo from '../../entity/VideoDetailInfo';
import HttpUtils from '../../utils/HttpUtils';
import DataSource from '../DataSource';
import { parseDocument } from 'htmlparser2'
import * as DomUtils from 'domutils'
import { Element, Document, AnyNode } from "domhandler"

const PREFIX_DATA = "var player_aaaa="

export default class BimiAcgDataSource implements DataSource {

    async search(keyword: string, page: number): Promise<VideoInfo[]> {
        let url = "http://www.bimiacg4.net/vod/search/wd/" + encodeURIComponent(keyword) + "/page/" + page

        return this.parseVideoList(await HttpUtils.getHtml(url))
    }


    async getVideoList(page: number): Promise<VideoInfo[]> {
        let url = "http://www.bimiacg4.net/type/riman-" + page
        let doc = await HttpUtils.getHtml(url)
//        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
//        Logger.e(this, 'parseHtml drama=' + drama)
//        let elements = CssSelector.find(drama, 'li')
//        Logger.e(this, 'parseHtml elements=' + elements)
//        let videoList: VideoInfo[] = []
//
//        // TODO 代码优化
//        elements.forEach((el) => {
//            Logger.e(this, "parseHtml el=" + el)
//            let img = CssSelector.findFirst(el, 'img')
//            let a = CssSelector.findFirst(el, "div.info > a")
//            videoList.push({
//                url: "http://www.bimiacg4.net" + DomUtils.getAttributeValue(a as Element, 'href'),
//                imgUrl: DomUtils.getAttributeValue(img as Element, 'src'),
//                title: DomUtils.textContent(a),
//                episode: DomUtils.textContent(CssSelector.findFirst(el, "div.info > p > span.fl"))
//            })
//        })
//        return videoList
        return this.parseVideoList(doc)
    }

    private parseVideoList(doc) {
        let drama = CssSelector.findFirst(doc, 'ul.drama-module')
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
                url: "http://www.bimiacg4.net" + DomUtils.getAttributeValue(a as Element, 'href'),
                imgUrl: DomUtils.getAttributeValue(img as Element, 'src'),
                title: DomUtils.textContent(a),
                episode: DomUtils.textContent(CssSelector.findFirst(el, "div.info > p > span.fl"))
            })
        })
        return videoList
    }

    async getVideoDetailInfo(url: string): Promise<VideoDetailInfo> {
        try {

            let doc = await HttpUtils.getHtml(url);

            Logger.e(this, 'getVideoDetailInfo 1')
            let test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(3) > a")
            Logger.e(this, 'getVideoDetailInfo 2 test=' + test)

            test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(4)")
            Logger.e(this, 'getVideoDetailInfo 3 test=' + test)

            test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(5)")
            Logger.e(this, 'getVideoDetailInfo 4 test=' + test)

            test = CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(2)")
            Logger.e(this, 'getVideoDetailInfo 5 test=' + test)

            let info: VideoDetailInfo = {
                title: DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > div > h1")),
                url: '',
                desc: DomUtils.textContent(CssSelector.findFirst(doc, "li.li_intro")),
                coverUrl: DomUtils.getAttributeValue(CssSelector.findFirst(doc, "div.poster_placeholder > div > img") as Element, 'src'),
                category: DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(3) > a")),
                director: DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(4)")),
                updateTime: DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(5)")),
                protagonist: DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > ul > li:nth-child(2)")),
                episodes: await this.getEpisodes(doc),
                recommends: await this.getRecommends(doc)
            }
            return info
        } catch (e) {
            Logger.e(this, 'getVideoDetailInfo error: ' + JSON.stringify(e))
            throw e;
        }
    }

    async getEpisodes(doc: Document): Promise<EpisodeList[]> {

        let list: EpisodeList[] = []
        let elements = CssSelector.find(doc, "ul.player_list")
        let title = DomUtils.textContent(CssSelector.findFirst(doc, "div.txt_intro_con > div > h1"))
        elements.forEach((el, i) => {
            let episodeList: EpisodeList = {
                title: "路线" + i,
                episodes: []
            }

            CssSelector.find(el, 'a').forEach((a) => {
                let info: EpisodeInfo = {
                    link: "http://www.bimiacg4.net" + DomUtils.getAttributeValue(a as Element, 'href'),
                    title: DomUtils.textContent(a),
                    desc: title + ' ' + DomUtils.textContent(a)
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
                url: "http://www.bimiacg4.net" + DomUtils.getAttributeValue(a as Element, 'href'),
                imgUrl: DomUtils.getAttributeValue(img as Element, 'src'),
                title: DomUtils.textContent(a),
                episode: DomUtils.textContent(CssSelector.findFirst(elInfo, "span.fl")),
                updateTime: DomUtils.textContent(CssSelector.findFirst(elInfo, 'em.fr'))
            })
        })
        return videoList
    }

    async parseVideoUrl(link: string): Promise<string> {
        let doc = await HttpUtils.getHtml(link)
        let video = CssSelector.findFirst(doc, 'div#video')
        let scripts = CssSelector.find(video, 'script')

        for (let script of scripts) {
            let text = DomUtils.textContent(script)
            Logger.e(this, 'script text=' + text)
            if (text.startsWith(PREFIX_DATA)) {
                text = text.substring(PREFIX_DATA.length)
                Logger.e(this, 'substring script text=' + text)
                let obj = JSON.parse(text)
                let picUrl = "http://www.bimiacg4.net/static/danmu/pic.php?url=" + obj["url"];
                doc = await HttpUtils.getHtml(picUrl)
                let src = DomUtils.getAttributeValue(CssSelector.findFirst(doc, 'source') as Element, 'src')
                Logger.e(this, 'parseVideoUrl src=' + src)
                let url
                if (src.startsWith('./')) {
                    url = src.replace("./", "http://www.bimiacg4.net/static/danmu/")
                } else {
                    url = src
                }
                Logger.e(this, 'parseVideoUrl url=' + url)
                return url
            }
        }
        return null;
    }
}