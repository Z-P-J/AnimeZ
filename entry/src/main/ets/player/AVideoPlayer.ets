import IPlayer from './IPlayer';
import IPlayerManager, { PlayerListener, PlayerStatus, VideoFit } from './IPlayerManager';
import media from '@ohos.multimedia.media';
import { VideoPlayerController } from './VideoPlayerController';
import EpisodeInfo from '../entity/EpisodeInfo';
import DisplayUtils from '../utils/DisplayUtils';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import Logger from '../utils/Logger';

const DEFAULT_ASPECT = 1.9

/**
 * 封装media.AVPlayer
 */
class AVPlayerWrapper {
  private readonly avPlayer: media.AVPlayer
  private surfaceId: string

  constructor(avPlayer: media.AVPlayer) {
    this.avPlayer = avPlayer
  }

  async init(manager: IPlayerManager, surfaceId: string): Promise<void> {
    this.surfaceId = surfaceId
    this.bindState(this.avPlayer, manager)
    manager.init(this.getPlayer())
  }

  private getPlayer(): IPlayer {
    return {
      setDataSource: async (url: string) => {
        if (this.avPlayer.url == url) {
          return
        }
        Logger.e(this, 'setDataSource url=' + url)
        this.avPlayer.url = url
      },
      start: async () => {
        Logger.e(this, 'setDataSource start')
        return this.avPlayer.play()
      },
      prepare: async () => {
        //      this.controller.prepareAsync()
        Logger.e(this, 'setDataSource prepare')
        return this.avPlayer.prepare()
      },
      pause: async () => {
        Logger.e(this, 'setDataSource pause')
        return this.avPlayer.pause()
      },
      stop: async () => {
        Logger.e(this, 'setDataSource stop')
        return this.avPlayer.stop()
      },
      reset: async () => {
        Logger.e(this, 'setDataSource reset')
        return this.avPlayer.reset()
      },
      release: async () => {
        Logger.e(this, 'setDataSource release')
        return this.avPlayer.release()
      },
      seekTo: async (value: number) => {
        Logger.e(this, 'setDataSource seekTo value=' + value)
        return this.avPlayer.seek(value)
      },
      setSpeed: async (speed: PlaybackSpeed) => {
        return this.setSpeed(speed)
      }
    }
  }

  async setSpeed(speed: PlaybackSpeed) {
    let avSpeed: media.PlaybackSpeed
    switch (speed) {
      case PlaybackSpeed.Speed_Forward_0_75_X:
        avSpeed = media.PlaybackSpeed.SPEED_FORWARD_0_75_X
        break
      case PlaybackSpeed.Speed_Forward_1_25_X:
        avSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_25_X
        break
      case PlaybackSpeed.Speed_Forward_1_75_X:
        avSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_75_X
        break
      case PlaybackSpeed.Speed_Forward_2_00_X:
        avSpeed = media.PlaybackSpeed.SPEED_FORWARD_2_00_X
        break
      case PlaybackSpeed.Speed_Forward_1_00_X:
      default:
        avSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
        break
    }
    return this.avPlayer.setSpeed(avSpeed)
  }

  private bindState(avPlayer: media.AVPlayer, manager: IPlayerManager) {
    avPlayer.on('stateChange', (state: media.AVPlayerState) => {
      Logger.e(this, 'AVPlayer stateChange state=' + state)
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          if (!avPlayer.surfaceId) {
            avPlayer.surfaceId = this.surfaceId;
          }
          manager.setStatus(PlayerStatus.INITIALIZED)
          break;
        case 'prepared':
          avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
          manager.setStatus(PlayerStatus.PREPARED)
          break;
        case 'playing':
          manager.setStatus(PlayerStatus.PLAY)
          break;
        case 'paused':
          manager.setStatus(PlayerStatus.PAUSE)
          break;
        case 'completed':
          manager.setStatus(PlayerStatus.DONE)
          break;
        case 'stopped':
          manager.setStatus(PlayerStatus.STOP)
          break;
        case 'released':
          manager.setStatus(PlayerStatus.IDLE)
          break;
        case 'error':
          manager.setStatus(PlayerStatus.ERROR)
          break;
        default:
          break;
      }
    });
    avPlayer.on('timeUpdate', (time: number) => {
      Logger.e(this, 'timeUpdate time=' + time)
      manager.notifyCurrentTime(time)
    });
    avPlayer.on('durationUpdate', (time: number) => {
      Logger.e(this, 'durationUpdate time=' + time)
      manager.notifyDuration(time)
    });
    avPlayer.on('seekDone', (value: number) => {
      Logger.e(this, 'seekDone value=' + value)
    })
    avPlayer.on('videoSizeChange', (w: number, h: number) => {
      Logger.e(this, 'videoSizeChange w=' + w + ' h=' + h)
      manager.onVideoSizeChanged(w, h)
    })
    avPlayer.on('error', (error) => {
      Logger.e(this, 'onError e=' + JSON.stringify(error))
      manager.setStatus(PlayerStatus.ERROR)
    })
    avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      Logger.e(this, 'bufferingUpdate infoType=' + infoType + ' value=' + value)
      manager.notifyBuffering(infoType, value)
    })
  }
}

/**
 * 封装AVPlayer实现播放器控件
 */
@Component
export struct AVideoPlayer {
  @State videoAspRatio: number = DEFAULT_ASPECT
  @State aspRatio: number = DEFAULT_ASPECT
  @State playerStatus: number = PlayerStatus.IDLE
  @State isFullScreen: boolean = false
  @State videoUrl: string = ''
  @State videoSpeed: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  private originalVideoAspRatio: number = DEFAULT_ASPECT;
  private readonly componentController: XComponentController = new XComponentController()
  private playerManager: IPlayerManager = null
  private immersionStatusBar: boolean = false
  private timer: number = -1;

  /**
   * 播放器监听回调
   */
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status
    },
    onEpisodeChanged: (episodeList: EpisodeInfo[], episodeIndex: number) => {
      this.videoUrl = episodeList[episodeIndex].videoUrl
    },
    onVideoSpeedChanged: (videoSpeed: PlaybackSpeed) => {
      this.videoSpeed = videoSpeed
    },
    onVideoFitChanged: (videoFit: VideoFit) => {
      switch (videoFit) {
        case VideoFit.Contain:
          this.videoAspRatio = this.originalVideoAspRatio
          break
        case VideoFit.Cover:
          this.videoAspRatio = this.aspRatio
          break
        case VideoFit.Fill:
          this.videoAspRatio = this.originalVideoAspRatio
          break
        case VideoFit.Fit_16_9:
          this.videoAspRatio = 16 / 9
          break
        case VideoFit.Fit_4_3:
          this.videoAspRatio = 4 / 3
          break
        case VideoFit.Fit_1_1:
          this.videoAspRatio = 1
          break
        default:
          this.videoAspRatio = DEFAULT_ASPECT
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
    },
    onVideoSizeChange: (w: number, h: number) => {
      Logger.e(this, 'onVideoSizeChange w=' + w + ' h=' + h)
      this.originalVideoAspRatio = w / h
      animateTo({
        duration: 360,
        curve: Curve.Smooth,
        iterations: 1,
        playMode: PlayMode.Normal
      }, () => {
        this.videoAspRatio = w / h
        if (this.isFullScreen) {
          this.aspRatio = DisplayUtils.getRealScreenHWRatio()
        } else {
          this.aspRatio = Math.min(DEFAULT_ASPECT, this.videoAspRatio);
        }
        Logger.e(this, 'VideoSizeChange w=' + w + ' h=' + h + ' videoAspRatio=' + this.videoAspRatio + ' aspRatio=' + this.aspRatio)
      })
    },
    onProgressChange: (totalTime: number, currentTime: number) => {

    },
    onBuffering: (type: media.BufferingInfoType, value: number) => {
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
        XComponent({
          id: '',
          type: 'surface',
          libraryname: '',
          controller: this.componentController
        })
          .onLoad((context) => {
            const surfaceId = this.componentController.getXComponentSurfaceId()
            Logger.e(this, 'XComponent onLoad surfaceId=' + surfaceId)
            media.createAVPlayer()
              .then((player) => {
                const avPlayer: AVPlayerWrapper = new AVPlayerWrapper(player)
                avPlayer.init(this.playerManager, surfaceId)
              })
          })
          .onDestroy(() => {
            Logger.e(this, 'XComponent onDestroy')
          })
          .width('100%')
          .aspectRatio(this.videoAspRatio)

        VideoPlayerController({ playerManager: this.playerManager })
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