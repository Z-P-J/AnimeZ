import { VideoFit } from '../player/SystemPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import { PlayerListener } from '../player/SystemPlayerManager';
import { SystemVideoPlayer } from '../player/SystemVideoPlayer';
import SystemPlayerManager from '../player/SystemPlayerManager';
import Logger from '../utils/Logger';
import router from '@ohos.router';

/**
 * 本地视频播放页面
 */
@Entry
@Component
struct LocalVideoPlayerPage {
  //  private playerManager: PlayerManager = new PlayerManager()
  //  private url: string
  //
  //  aboutToAppear() {
  //    this.url = router.getParams()['video_path']
  //    Logger.e(this, 'aboutToAppear url=' + this.url)
  //    this.playerManager.addFullScreenChangeListener((isFullScreen) => {
  //      if (!isFullScreen) {
  //        // 退出全屏模式时关闭当前页面
  //        router.back()
  //      }
  //    })
  //    this.playerManager.setPlayerUrl(this.url)
  //    // 直接进入全屏模式
  //    this.playerManager.enterFullScreen()
  //    this.playerManager.start()
  //  }
  //
  //  aboutToDisappear() {
  //    this.playerManager.exitFullScreen()
  //    this.playerManager.destroy()
  //  }
  //
  //  build() {
  //    Stack() {
  //      VideoPlayer({ playerManager: this.playerManager, immersionStatusBar: false })
  //    }
  //    .height('100%')
  //    .width('100%')
  //  }


  private playerManager: SystemPlayerManager = new SystemPlayerManager()
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
    },
    onEpisodeChanged: (episode: EpisodeInfo) => {
    },
    onVideoSpeedChanged: (videoSpeed: number) => {
    },
    onVideoFitChanged: (videoFit: VideoFit) => {
    },
    onFullScreenChanged: (isFullScreen: boolean) => {
      if (!isFullScreen) {
        // 退出全屏模式时关闭当前页面
        router.back()
      }
    }
  }

  aboutToAppear() {
    let episode: EpisodeInfo = router.getParams()['episode']
    Logger.e(this, 'aboutToAppear episode=' + JSON.stringify(episode))
    this.playerManager.addListener(this.playerListener)
    this.playerManager.setEpisode(episode)
    // 直接进入全屏模式
    this.playerManager.enterFullScreen()
    this.playerManager.start()
  }

  aboutToDisappear() {
    this.playerManager.removeListener(this.playerListener)
    this.playerManager.exitFullScreen()
    this.playerManager.destroy()
  }

  build() {
    Stack() {
      SystemVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: false })
    }
    .height('100%')
    .width('100%')
  }
}