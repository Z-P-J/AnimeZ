import Logger from '../utils/Logger';
import router from '@ohos.router';
import { VideoPlayer } from '../player/VideoPlayer';
import { PlayerManager } from '../player/PlayerManager';

/**
 * 本地视频播放页面
 */
@Entry
@Component
struct LocalVideoPlayerPage {
  private playerManager: PlayerManager = new PlayerManager()
  private url: string

  aboutToAppear() {
    this.url = router.getParams()['video_path']
    Logger.e(this, 'aboutToAppear url=' + this.url)
    this.playerManager.addFullScreenChangeListener((isFullScreen) => {
      if (!isFullScreen) {
        // 退出全屏模式时关闭当前页面
        router.back()
      }
    })
    this.playerManager.setPlayerUrl(this.url)
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
    .height('100%')
    .width('100%')
  }
}