import { VideoFit } from './SystemPlayerManager';
import SystemPlayerManager, { PlayerListener } from './SystemPlayerManager';
import { SystemPlayerController } from './SystemPlayerController';
import EpisodeInfo from '../entity/EpisodeInfo';
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
  @State playerStatus: number = PlayerStatus.INIT
  @State isFullScreen: boolean = false
  @State videoUrl: string = ''
  @State videoSpeed: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @State videoFit: ImageFit = ImageFit.Contain
  private playerManager: SystemPlayerManager = null
  private immersionStatusBar: boolean = false
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status
    },
    onEpisodeChanged: (episode: EpisodeInfo) => {
      this.videoUrl = episode.videoUrl
    },
    onVideoSpeedChanged: (videoSpeed: PlaybackSpeed) => {
      this.videoSpeed = videoSpeed
    },
    onVideoFitChanged: (videoFit: VideoFit) => {
      switch (videoFit) {
        case VideoFit.Contain:
          this.videoAspRatio = DEFAULT_ASPECT
          this.videoFit = ImageFit.Contain
          break
        case VideoFit.Cover:
          this.videoAspRatio = DEFAULT_ASPECT
          this.videoFit = ImageFit.Cover
          break
        case VideoFit.Fill:
          this.videoAspRatio = DEFAULT_ASPECT
          this.videoFit = ImageFit.Fill
          break
        case VideoFit.Fit_16_9:
          this.videoAspRatio = 16 / 9
          this.videoFit = ImageFit.Fill
          break
        case VideoFit.Fit_4_3:
          this.videoAspRatio = 4/ 3
          this.videoFit = ImageFit.Fill
          break
        case VideoFit.Fit_1_1:
          this.videoAspRatio = 1
          this.videoFit = ImageFit.Fill
          break
        default:
          this.videoAspRatio = DEFAULT_ASPECT
          this.videoFit = ImageFit.Contain
          break
      }
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

        Video({ src: this.videoUrl, currentProgressRate: this.videoSpeed, controller: this.playerManager.controller })
          .width('100%')
          .controls(false)
          .autoPlay(true)
          .objectFit(this.videoFit)
          .aspectRatio(this.videoAspRatio)
          .onStart(() => {
            Logger.e(this, 'onStart')
            this.playerManager.setStatus(PlayerStatus.PLAY)
          })
          .onError(() => {
            Logger.e(this, 'onError')
            this.playerManager.setStatus(PlayerStatus.ERROR)
          })
          .onPrepared((e) => {
            Logger.e(this, 'onPrepared')
            this.playerManager.notifyDuration(e.duration)
          })
          .onPause(() => {
            Logger.e(this, 'onPause')
            if (!this.playerManager.isPrepared()) {
              this.playerManager.setStatus(PlayerStatus.BUFFERING)
            } else {
              this.playerManager.setStatus(PlayerStatus.PAUSE)
            }
          })
          .onSeeking((e) => {
            Logger.e(this, 'onSeeking time=' + e.time)
            this.playerManager.setStatus(PlayerStatus.BUFFERING)
          })
          .onSeeked((e) => {
            Logger.e(this, 'onSeeked time=' + e.time)
          })
          .onFinish(() => {
            Logger.e(this, 'onFinish')
            this.playerManager.setStatus(PlayerStatus.DONE)
          })
          .onUpdate((e) => {
            Logger.e(this, 'onUpdate')
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