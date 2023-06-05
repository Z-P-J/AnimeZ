import { SystemPlayerController } from './SystemPlayerController';
import EpisodeInfo from '../entity/EpisodeInfo';
import PlayerListener from './SystemPlayerManager';
import { SystemPlayerManager } from './SystemPlayerManager';
import DisplayUtils from '../utils/DisplayUtils';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { PlayerStatus } from './PlayerStatus';
import { PlayerController } from './PlayerController';
import Logger from '../utils/Logger';

const DEFAULT_ASPECT = 1.9

/**
 * 视频播放器，封装系统Video
 */
@Component
export struct SystemVideoPlayer {
  @State videoAspRatio: number = DEFAULT_ASPECT
  @State aspRatio: number = DEFAULT_ASPECT
  @State playStatus: number = PlayerStatus.INIT;
  @State playerStatus: number = PlayerStatus.INIT
  @State isFullScreen: boolean = false
  @State videoUrl: string = null


  private playerManager: SystemPlayerManager = null
  private immersionStatusBar: boolean = false

  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status
    },
    onEpisodeChanged: (episode: EpisodeInfo) => {
      this.videoUrl = episode.videoUrl
    },
    onVideoSpeedChanged: (videoSpeed: number) => {

    },
    onFullScreenChanged: (isFullScreen: boolean) => {
      this.isFullScreen = isFullScreen
      animateTo({
        duration: 360,
        curve: Curve.Smooth,
        iterations: 1,
        playMode: PlayMode.Normal
      }, () => {
        if (isFullScreen) {
          this.aspRatio = DisplayUtils.getRealScreenHWRatio()
        } else {
          this.aspRatio = Math.min(DEFAULT_ASPECT, this.videoAspRatio);
        }
      })
    }
  }

  aboutToAppear() {
    if (this.playerManager) {
      this.playerManager.addListener(this.playerListener)
    } else {
      throw new Error('You must set playerManager firstly!')
    }
  }

  aboutToDisappear() {
    this.playerManager.removeListener(this.playerListener)
  }

  build() {
    Column() {
      if (!this.isFullScreen && this.immersionStatusBar) {
        ImmersionBarSpace().backgroundColor(Color.Black)
      }
      Stack({ alignContent: Alignment.Center }) {

        Video({ src: this.videoUrl, controller: this.playerManager.controller })
          .width('100%')
          .controls(false)
          .objectFit(ImageFit.Cover)
          .aspectRatio(this.videoAspRatio)
          .onStart(() => {
            this.playerManager.setStatus(PlayerStatus.PLAY)
          })
          .onError(() => {
            this.playerManager.setStatus(PlayerStatus.ERROR)
          })
          .onPrepared((e) => {
            this.playerManager.notifyDuration(e.duration)
          })
          .onPause(() => {
//            this.playStatus = PlayerStatus.PAUSE
            if (!this.playerManager.isPrepared()) {
              this.playerManager.setStatus(PlayerStatus.BUFFERING)
            } else {
              this.playerManager.setStatus(PlayerStatus.PAUSE)
            }
          })
          .onFinish(() => {
            this.playerManager.setStatus(PlayerStatus.DONE)
          })
          .onUpdate((e) => {
            this.playerManager.notifyCurrentTime(e.time)
          })
        SystemPlayerController({ playerManager: this.playerManager })
          .width('100%')
          .height('100%')
      }
      .backgroundColor(Color.Black)
      .width('100%')
      .aspectRatio(this.aspRatio)
    }
    .width('100%')
  }
}