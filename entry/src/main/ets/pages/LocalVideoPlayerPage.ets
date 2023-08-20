import IPlayerManager, { VideoFit } from '../player/IPlayerManager';
import fs from '@ohos.file.fs';
import { AVideoPlayer } from '../player/AVideoPlayer';
import PlayerManagerImpl from '../player/PlayerManagerImpl';
import EpisodeInfo from '../entity/EpisodeInfo';
import { getTheme } from '../utils/Themes';
import { IjkVideoPlayer } from '../player/IjkVideoPlayer';
import Logger from '../utils/Logger';
import router from '@ohos.router';

/**
 * 本地视频播放页面
 * TODO 暂时只能用IjkPlayer播放本地m3u8视频，AVPlayer和Video控件目前播放不了本地缓存的m3u8
 */
@Entry
@Component
struct LocalVideoPlayerPage {
  @StorageLink('theme') theme: number = 0
  private playerManager: IPlayerManager = new PlayerManagerImpl()

  aboutToAppear() {
    let episode: EpisodeInfo = router.getParams()['episode']
    Logger.e(this, 'aboutToAppear episode=' + JSON.stringify(episode))
    this.playerManager.addListener({
      onStatusChanged: (status: number) => {
      },
      onEpisodeChanged: (episodeList: EpisodeInfo[], episodeIndex: number) => {
      },
      onVideoSpeedChanged: (videoSpeed: PlaybackSpeed) => {
      },
      onVideoFitChanged: (videoFit: VideoFit) => {
      },
      onFullScreenChanged: (isFullScreen: boolean) => {
        if (!isFullScreen) {
          // 退出全屏模式时关闭当前页面
          router.back()
        }
      },
      onVideoSizeChange: (w: number, h: number) => {
      },
      onProgressChange: (totalTime: number, currentTime: number) => {
      },
      onBuffering: (type, value) => {
      }
    })

    // 直接进入全屏模式
    this.playerManager.enterFullScreen()

    // TODO 本地文件转fd://
    //    if (episode.videoUrl && episode.videoUrl.startsWith('/')) {
    //      // 本地视频文件
    //      fs.open(episode.videoUrl, fs.OpenMode.READ_ONLY, (err, file) => {
    //        if (err) {
    //          this.playerManager.setStatus(PlayerStatus.ERROR)
    //        } else {
    //          episode.videoUrl = 'fd://' + file.fd
    //          Logger.e(this, 'open local video, uri=' + episode.videoUrl)
    //          this.playerManager.playEpisode(episode)
    //        }
    //      });
    //    } else {
    //      this.playerManager.playEpisode(episode)
    //    }
    this.playerManager.playEpisodeList([episode], 0)
  }

  aboutToDisappear() {
    this.playerManager.exitFullScreen()
    this.playerManager.destroy()
  }

  build() {
    Stack() {
      IjkVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: false })
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .height('100%')
    .width('100%')
  }
}