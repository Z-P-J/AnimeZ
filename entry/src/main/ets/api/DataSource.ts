import HomepageData from '../entity/HomepageData';
import EpisodeList from '../entity/EpisodeList'
import VideoInfo from '../entity/VideoInfo'
import VideoDetailInfo from '../entity/VideoDetailInfo'
import { Document } from "domhandler"

export default interface DataSource {

    search(keyword: string, page: number): Promise<VideoInfo[]>

    getHomepageData(): Promise<HomepageData>

    getVideoList(page: number): Promise<VideoInfo[]>
    
//    getBannerList(): Promise<VideoInfo[]>

    getVideoDetailInfo(url: string): Promise<VideoDetailInfo>

    getEpisodes(doc: Document): Promise<EpisodeList[]>

    getRecommends(doc: Document): Promise<VideoInfo[]>

    parseVideoUrl(link: string): Promise<string>


}