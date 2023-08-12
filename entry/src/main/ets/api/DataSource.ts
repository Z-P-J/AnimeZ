import HomepageData from '../entity/HomepageData';
import EpisodeList from '../entity/EpisodeList'
import VideoInfo from '../entity/VideoInfo'
import VideoDetailInfo from '../entity/VideoDetailInfo'
import { Document } from "domhandler"

/**
 * 数据源
 */
export default interface DataSource {

    /**
     * 搜索视频
     */
    search(keyword: string, page: number): Promise<VideoInfo[]>

    /**
     * 获取主页数据
     */
    getHomepageData(): Promise<HomepageData>

    /**
     * 获取某页视频数据
     */
    getVideoList(page: number): Promise<VideoInfo[]>
    
//    getBannerList(): Promise<VideoInfo[]>

    /**
     * 获取视频详情
     */
    getVideoDetailInfo(url: string): Promise<VideoDetailInfo>

//    /**
//     * 获取播放列表
//     */
//    getEpisodes(doc: Document): Promise<EpisodeList[]>
//
//    /**
//     * 获取推荐视频
//     */
//    getRecommends(doc: Document): Promise<VideoInfo[]>

    /**
     * 解析视频链接
     */
    parseVideoUrl(link: string): Promise<string>


}