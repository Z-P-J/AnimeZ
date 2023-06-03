import EpisodeList from './EpisodeList';
import VideoInfo from './VideoInfo';

/**
 * 视频详情信息
 */
export default interface VideoDetailInfo extends VideoInfo {

    /**
     * 封面链接
     */
    coverUrl?: string
    /**
     * 视频描述
     */
    desc?: string
    /**
     * 分类信息
     */
    category?: string
    /**
     * 导演信息
     */
    director?: string
    /**
     * 播放列表
     */
    episodes?: EpisodeList[];
    /**
     * 推荐视频
     */
    recommends?: VideoInfo[];

}