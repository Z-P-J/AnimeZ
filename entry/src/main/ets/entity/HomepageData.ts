import VideoInfo from './VideoInfo';

export interface DramaList {
    title: string
    moreUrl: string
    videoList: VideoInfo[]
}

export default interface HomepageData {

    bannerList: VideoInfo[]

    categoryList: DramaList[]


}