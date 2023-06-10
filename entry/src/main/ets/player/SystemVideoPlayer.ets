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

  private timer: number = -1;

  /**
   * 播放器监听回调
   */
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
    if (this.timer >= 0) {
      clearTimeout(this.timer)
      this.timer = -1
    }
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
            let status = this.playerManager.getStatus()
            Logger.e(this, 'onPause currentStatus=' + status)
            if (status == PlayerStatus.ERROR || status == PlayerStatus.STOP) {
              return
            }
            if (!this.playerManager.isPrepared()) {
              this.playerManager.setStatus(PlayerStatus.BUFFERING)
            } else {
              if (status == PlayerStatus.PLAY || status == PlayerStatus.BUFFERING) {
                // 播放或缓冲时可以暂停视频
                this.playerManager.setStatus(PlayerStatus.PAUSE)
              }
            }
          })
          .onSeeking((e) => {
            // TODO seek时没有回调该函数？
            Logger.e(this, 'onSeeking time=' + e.time)
            this.playerManager.setStatus(PlayerStatus.BUFFERING)
          })
          .onSeeked((e) => {
            // TODO seek时没有回调该函数？
            Logger.e(this, 'onSeeked time=' + e.time)
          })
          .onFinish(() => {
            Logger.e(this, 'onFinish')
            this.playerManager.setStatus(PlayerStatus.DONE)
          })
          .onUpdate((e) => {
            Logger.e(this, 'onUpdate time=' + e.time + ' status=' + this.playerManager.getStatus())
            this.checkPlayingStatus()
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

  /**
   * Video每隔一秒会更新播放进度，如果超过一秒（暂时设为1200ms）没有更新播放进度，则判断为此时可能是在缓冲视频
   */
  private checkPlayingStatus() {
    // 清除已存在的timer
    if (this.timer >= 0) {
      clearTimeout(this.timer)
      this.timer = -1
    }

    this.timer = setTimeout(() => {
      if (this.timer < 0) {
        return
      }
      this.timer = -1
      if (this.playerManager.isPlaying()) {
        this.playerManager.setStatus(PlayerStatus.BUFFERING)
      }
    }, 1100)
  }


}