import { SystemVideoPlayer } from '../player/SystemVideoPlayer';
import { PlayerListener } from '../player/SystemPlayerManager';
import SystemPlayerManager from '../player/SystemPlayerManager';
import { VideoFit } from '../player/SystemPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import { getTheme } from '../utils/Themes';
import { VideoPlayer } from '../player/VideoPlayer';
import { PlayerManager } from '../player/PlayerManager';
import Logger from '../utils/Logger';
import router from '@ohos.router';

/**
 * 本地视频播放页面
 */
@Entry
@Component
struct LocalVideoPlayerPage {
    @StorageLink('theme') theme: number = 0
    private playerManager: PlayerManager = new PlayerManager()

    aboutToAppear() {
      let episode = router.getParams()['episode']
      Logger.e(this, 'aboutToAppear episode=' + JSON.stringify(episode))
      this.playerManager.addFullScreenChangeListener((isFullScreen) => {
        if (!isFullScreen) {
          // 退出全屏模式时关闭当前页面
          router.back()
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
        VideoPlayer({ playerManager: this.playerManager, immersionStatusBar: false })
      }
      .backgroundColor(getTheme(this.theme).background_color_accent)
      .height('100%')
      .width('100%')
    }


//  private playerManager: SystemPlayerManager = new SystemPlayerManager()
//  private readonly playerListener: PlayerListener = {
//    onStatusChanged: (status: number) => {
//    },
//    onEpisodeChanged: (episode: EpisodeInfo) => {
//    },
//    onVideoSpeedChanged: (videoSpeed: number) => {
//    },
//    onVideoFitChanged: (videoFit: VideoFit) => {
//    },
//    onFullScreenChanged: (isFullScreen: boolean) => {
//      if (!isFullScreen) {
//        // 退出全屏模式时关闭当前页面
//        router.back()
//      }
//    }
//  }
//
//  aboutToAppear() {
//    let episode: EpisodeInfo = router.getParams()['episode']
//    Logger.e(this, 'aboutToAppear episode=' + JSON.stringify(episode))
//    this.playerManager.addListener(this.playerListener)
//    this.playerManager.setEpisode(episode)
//    // 直接进入全屏模式
//    this.playerManager.enterFullScreen()
//    this.playerManager.start()
//  }
//
//  aboutToDisappear() {
//    this.playerManager.removeListener(this.playerListener)
//    this.playerManager.exitFullScreen()
//    this.playerManager.destroy()
//  }
//
//  build() {
//    Stack() {
//      SystemVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: false })
//    }
//    .backgroundColor(getTheme(this.theme).background_color_accent)
//    .height('100%')
//    .width('100%')
//  }
}