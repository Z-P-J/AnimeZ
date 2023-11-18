import { DramaList } from '../../entity/HomepageData';
import HomepageData from '../../entity/HomepageData';
import Logger from '../../utils/Logger';
import EpisodeInfo from '../../entity/EpisodeInfo';
import VideoInfo from '../../entity/VideoInfo';
import EpisodeList from '../../entity/EpisodeList';
import VideoDetailInfo from '../../entity/VideoDetailInfo';
import HttpUtils from '../../utils/HttpUtils';
import DataSource from '../DataSource';
import { select, selectAttributeValue, selectFirst, selectTextContent, textContent } from '../../thirdpart/htmlsoup';

const BASE_URL = 'http://www.yinghuavideo.com/'

/**
 * 樱花动漫 (http://www.yinghuavideo.com) 视频源
 */
export default class YingHuaDataSource implements DataSource {

    getKey(): string {
        return 'key_yinghuavideo'
    }

    async search(keyword: string, page: number): Promise<VideoInfo[]> {
        let url = BASE_URL + "search/" + encodeURIComponent(keyword) + "/?page=" + page

        let videos: VideoInfo[] = []
        let doc = await HttpUtils.getHtml(url)
        const list = select(doc, 'div.fire > div > ul > li')
        list.forEach((li) => {
            let a = selectFirst(li, "a")
            let img = selectFirst(li, 'img')
            videos.push({
                sourceKey: this.getKey(),
                url: 'http://www.yinghuavideo.com' + a.attr('href'),
                imgUrl: img.attr('src'),
                title: img.attr('alt'),
                episode: selectTextContent(li, 'span:nth-child(3) > font')
            })
        })
        return videos
    }

    async getHomepageData(): Promise<HomepageData> {
        let url = BASE_URL
        const doc = await HttpUtils.getHtml(url)
        const bannerList: VideoInfo[] = []
        const categoryList: DramaList[] = []
        const lis = select(doc, 'div.hero-wrap > ul.heros > li')
        lis.forEach((li) => {
            const a = selectFirst(li, "a")
            const img = selectFirst(li, 'img')
            bannerList.push({
                sourceKey: this.getKey(),
                url: 'http://www.yinghuavideo.com' + a.attr('href'),
                imgUrl: img.attr('src'),
                title: a.attr('title'),
                episode: selectTextContent(li, 'em')
            })
        })

        const titles = select(doc, 'div.firs > div.dtit')
        const videoList = select(doc, 'div.firs > div.img')

        const count = Math.min(titles.length, videoList.length)
        for (let i = 0; i < count; i++) {
            const title = titles[i]
            const list = videoList[i]
            const videos: VideoInfo[] = []
            const lis = select(list, 'ul > li')
            lis.forEach((li) => {
                let a = selectFirst(li, "a")
                let img = selectFirst(li, 'img')
                videos.push({
                    sourceKey: this.getKey(),
                    url: 'http://www.yinghuavideo.com' + a.attr('href'),
                    imgUrl: img.attr('src'),
                    title: selectTextContent(li, 'p.tname > a'),
                    episode: selectTextContent(li, 'p:nth-child(3) > a')
                })
            })

            categoryList.push({
                title: selectTextContent(title, "h2 > a"),
                moreUrl: BASE_URL + selectAttributeValue(title, 'span > a', 'href'),
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
        let drama = selectFirst(doc, 'ul.drama-module')
        return this.parseVideoList(drama)
    }

    private async parseVideoList(drama): Promise<VideoInfo[]> {
        //        let drama = selectFirst(doc, 'ul.drama-module')
        Logger.e(this, 'parseHtml drama=' + drama)
        let elements = select(drama, 'li')
        Logger.e(this, 'parseHtml elements=' + elements)
        let videoList: VideoInfo[] = []

        // TODO 代码优化
        elements.forEach((el) => {
            Logger.e(this, "parseHtml el=" + el)
            let a = selectFirst(el, "div.info > a")
            videoList.push({
                sourceKey: this.getKey(),
                url: "http://www.bimiacg4.net" + a.attr('href'),
                imgUrl: selectAttributeValue(el, 'img', 'src'),
                title: textContent(a),
                episode: selectTextContent(el, "div.info > p > span.fl")
            })
        })
        return videoList
    }

    async getVideoDetailInfo(url: string): Promise<VideoDetailInfo> {
        let doc = await HttpUtils.getHtml(url);

        Logger.e(this, 'getVideoDetailInfo 1')

        let title = selectTextContent(doc, 'div.fire > div.rate > h1')

        Logger.e(this, 'getVideoDetailInfo title=' + title)

        let recommends: VideoInfo[] = []
        let list = select(doc, 'div.sido > div.pics > ul > li')
        list.forEach((li) => {
            let a = selectFirst(li, "a")
            let img = selectFirst(li, 'img')
            recommends.push({
                sourceKey: this.getKey(),
                url: 'http://www.yinghuavideo.com' + a.attr('href'),
                imgUrl: img.attr('src'),
                title: img.attr('alt'),
                episode: selectTextContent(li, 'span:nth-child(3) > font')
            })
        })

        let episodes: EpisodeList[] = []
        let lis = select(doc, '#main0 > div > ul > li')
        Logger.e(this, 'getVideoDetailInfo lis.len=' + lis.length)
        let episodeList: EpisodeList = {
            title: "路线0",
            episodes: []
        }
        lis.reverse().forEach((li) => {
            const a = selectFirst(li, 'a')
            let info: EpisodeInfo = {
                link: 'http://www.yinghuavideo.com' + a.attr('href'),
                title: textContent(a),
                desc: title + ' ' + textContent(a)
            }
            Logger.e(this, 'getEpisodes info=' + JSON.stringify(info))
            episodeList.episodes.push(info)
        })
        episodes.push(episodeList)

        let info: VideoDetailInfo = {
            sourceKey: this.getKey(),
            title: title,
            url: url,
            desc: selectTextContent(doc, "div.fire > div.info").trim(),
            coverUrl: selectAttributeValue(doc, "div.fire > div.thumb > img", 'src'),
            category: selectTextContent(doc, 'div.fire > div.rate > div.sinfo > span:nth-child(3) > a'),
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

        let url = selectAttributeValue(doc, 'a#play_1', 'onclick')
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