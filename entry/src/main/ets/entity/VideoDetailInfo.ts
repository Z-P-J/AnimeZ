import EpisodeList from './EpisodeList';
import VideoInfo from './VideoInfo';


export default interface VideoDetailInfo extends VideoInfo {


    coverUrl?: string
    desc?: string
    category?: string
    director?: string
    episodes?: EpisodeList[];
    recommends?: VideoInfo[];

}