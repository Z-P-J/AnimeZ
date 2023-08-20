import IPlayerManager from './IPlayerManager';
import { IjkVideoPlayer } from './IjkVideoPlayer';
import { SystemVideoPlayer } from './SystemVideoPlayer';
import { AVideoPlayer } from './AVideoPlayer';
import Settings from '../utils/Settings';


/**
 * 支持多种视频播放器切换
 */
@Component
export struct MultiVideoPlayer {
  @State playerType: number = 0
  private playerManager: IPlayerManager = null
  private immersionStatusBar: boolean = false

  aboutToAppear() {
    if (!this.playerManager) {
      throw new Error('You must set playerManager firstly!')
    }
    this.playerType = Settings.getDefaultPlayerType()
  }

  build() {
    Stack() {
      if (this.playerType == 1) {
        SystemVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: this.immersionStatusBar })
      } else if (this.playerType == 2) {
        IjkVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: this.immersionStatusBar })
      } else {
        AVideoPlayer({ playerManager: this.playerManager, immersionStatusBar: this.immersionStatusBar })
      }
    }
    .width('100%')
  }
}