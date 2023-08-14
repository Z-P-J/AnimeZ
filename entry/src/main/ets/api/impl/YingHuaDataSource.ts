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

const BASE_URL = 'http://www.yinghuavideo.com/'

/**
 * 樱花动漫 (http://www.yinghuavideo.com) 视频源
 */
export default class YingHuaDataSource implements DataSource {
    async search(keyword: string, page: number): Promise<VideoInfo[]> {
        let url = BASE_URL + "search/" + encodeURIComponent(keyword) + "/?page=" + page

        let videos: VideoInfo[] = []
        let doc = await HttpUtils.getHtml(url)
        let list = CssSelector.find(doc, 'div.fire > div > ul > li')
        list.forEach((li) => {
            let a = CssSelector.findFirst(li, "a")
            let img = CssSelector.findFirst(li, 'img')
            videos.push({
                url: 'http://www.yinghuavideo.com' + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.getAttributeValue(img, 'src'),
                title: CssSelector.getAttributeValue(img, 'alt'),
                episode: CssSelector.selectTextContent(li, 'span:nth-child(3) > font')
            })
        })
        return videos
    }

    async getHomepageData(): Promise<HomepageData> {
        let url = BASE_URL
        let doc = await HttpUtils.getHtml(url)

        let bannerList: VideoInfo[] = []
        let categoryList: DramaList[] = []

        let lis = CssSelector.find(doc, 'div.hero-wrap > ul.heros > li')
        lis.forEach((li) => {
            let a = CssSelector.findFirst(li, "a")
            let img = CssSelector.findFirst(li, 'img')
            bannerList.push({
                url: 'http://www.yinghuavideo.com' + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.getAttributeValue(img, 'src'),
                title: CssSelector.getAttributeValue(a, 'title'),
                episode: CssSelector.selectTextContent(li, 'em')
            })
        })

        let titles = CssSelector.find(doc, 'div.firs > div.dtit')
        let videoList = CssSelector.find(doc, 'div.firs > div.img')

        let count = Math.min(titles.length, videoList.length)
        for (let i = 0; i < count; i++) {
            const title = titles[i]
            const list = videoList[i]
            let videos = []
            let lis = CssSelector.find(list, 'ul > li')
            lis.forEach((li) => {
                let a = CssSelector.findFirst(li, "a")
                let img = CssSelector.findFirst(li, 'img')
                videos.push({
                    url: 'http://www.yinghuavideo.com' + CssSelector.getAttributeValue(a, 'href'),
                    imgUrl: CssSelector.getAttributeValue(img, 'src'),
                    title: CssSelector.selectTextContent(li, 'p.tname > a'),
                    episode: CssSelector.selectTextContent(li, 'p:nth-child(3) > a')
                })
            })

            categoryList.push({
                title: CssSelector.selectTextContent(title, "h2 > a"),
                moreUrl: BASE_URL + CssSelector.selectAttributeValue(title, 'span > a', 'href'),
                videoList: videos
            })
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
            let a = CssSelector.findFirst(el, "div.info > a")
            videoList.push({
                url: "http://www.bimiacg4.net" + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.selectAttributeValue(el, 'img', 'src'),
                title: CssSelector.textContent(a),
                episode: CssSelector.selectTextContent(el, "div.info > p > span.fl")
            })
        })
        return videoList
    }

    async getVideoDetailInfo(url: string): Promise<VideoDetailInfo> {
        let doc = await HttpUtils.getHtml(url);

        Logger.e(this, 'getVideoDetailInfo 1')

        let title = CssSelector.selectTextContent(doc, 'div.fire > div.rate > h1')

        Logger.e(this, 'getVideoDetailInfo title=' + title)

        let recommends = []
        let list = CssSelector.find(doc, 'div.sido > div.pics > ul > li')
        list.forEach((li) => {
            let a = CssSelector.findFirst(li, "a")
            let img = CssSelector.findFirst(li, 'img')
            recommends.push({
                url: 'http://www.yinghuavideo.com' + CssSelector.getAttributeValue(a, 'href'),
                imgUrl: CssSelector.getAttributeValue(img, 'src'),
                title: CssSelector.getAttributeValue(img, 'alt'),
                episode: CssSelector.selectTextContent(li, 'span:nth-child(3) > font')
            })
        })

        let episodes: EpisodeList[] = []
        let lis = CssSelector.find(doc, '#main0 > div > ul > li')
        Logger.e(this, 'getVideoDetailInfo lis.len=' + lis.length)
        let episodeList: EpisodeList = {
            title: "路线0",
            episodes: []
        }
        lis.reverse().forEach((li) => {
            const a = CssSelector.findFirst(li, 'a')
            let info: EpisodeInfo = {
                link: 'http://www.yinghuavideo.com' + CssSelector.getAttributeValue(a, 'href'),
                title: CssSelector.textContent(a),
                desc: title + ' ' + CssSelector.textContent(a)
            }
            Logger.e(this, 'getEpisodes info=' + JSON.stringify(info))
            episodeList.episodes.push(info)
        })
        episodes.push(episodeList)

        let info: VideoDetailInfo = {
            title: title,
            url: url,
            desc: CssSelector.selectTextContent(doc, "div.fire > div.info").trim(),
            coverUrl: CssSelector.selectAttributeValue(doc, "div.fire > div.thumb > img", 'src'),
            category: CssSelector.selectTextContent(doc, 'div.fire > div.rate > div.sinfo > span:nth-child(3) > a'),
            director: '',
            updateTime: '',
            protagonist: '',
            episodes: episodes,
            recommends: recommends
        }
        return info
    }

    async parseVideoUrl(link: string): Promise<string> {
        Logger.e(this, 'parseVideoUrl link=' + link)
        const doc = await HttpUtils.getHtml(link)

        let url = CssSelector.selectAttributeValue(doc, 'a#play_1', 'onclick')
        Logger.e(this, 'parseVideoUrl old url=' + url)
        if (url) {
            url = url.substring(url.indexOf('\'') + 1, url.lastIndexOf('\''))
            const i = url.indexOf('$')
            if (i >= 0) {
                url = url.substring(0, i)
            }
        }
        Logger.e(this, 'parseVideoUrl url=' + url)
        return url;
    }
}