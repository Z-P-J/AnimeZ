import IPlayerManager from '../player/IPlayerManager';
import { VideoFit } from '../player/IPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import { getTheme } from '../utils/Themes';
import { IjkVideoPlayer } from '../player/IjkVideoPlayer';
import { IjkPlayerManager } from '../player/IjkPlayerManager';
import Logger from '../utils/Logger';
import router from '@ohos.router';

/**
 * 本地视频播放页面
 * TODO 暂时只能用IjkPlayer播放本地m3u8视频，Video控件目前播放不了本地缓存的m3u8
 */
@Entry
@Component
struct LocalVideoPlayerPage {
  @StorageLink('theme') theme: number = 0
  private playerManager: IPlayerManager = new IjkPlayerManager()

  aboutToAppear() {
    let episode = router.getParams()['episode']
    Logger.e(this, 'aboutToAppear episode=' + JSON.stringify(episode))
    this.playerManager.addListener({
      onStatusChanged: (status: number) => {
      },
      onEpisodeChanged: (episode: EpisodeInfo) => {
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
      }
    })
    this.playerManager.setEpisode(episode)
    // 直接进入全屏模式
    this.playerManager.enterFullScreen()
    this.playerManager.start()
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