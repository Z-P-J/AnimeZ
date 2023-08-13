import { SystemPlayerController } from './SystemPlayerController';
import IPlayerManager, { PlayerStatus, VideoFit, PlayerListener } from './IPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import DisplayUtils from '../utils/DisplayUtils';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import Logger from '../utils/Logger';

const DEFAULT_ASPECT = 1.9

/**
 * 视频播放器，封装IjkPlayer
 * TODO 重构
 */
@Component
export struct IjkVideoPlayer {
  @State videoAspRatio: number = DEFAULT_ASPECT
  @State aspRatio: number = DEFAULT_ASPECT
  @State playStatus: number = PlayerStatus.INIT
  @State playerStatus: PlayerStatus = PlayerStatus.INIT
  @State isFullScreen: boolean = false
  private readonly componentController: XComponentController = new XComponentController()
  private playerManager: IPlayerManager = null;
  private immersionStatusBar: boolean = false

  /**
   * 播放器监听回调
   */
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status
    },
    onEpisodeChanged: (episode: EpisodeInfo) => {
    },
    onVideoSpeedChanged: (videoSpeed: PlaybackSpeed) => {
    },
    onVideoFitChanged: (videoFit: VideoFit) => {
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
          //            this.componentController.setXComponentSurfaceSize({
          //              surfaceWidth: DisplayUtils.getRealScreenWidth(),
          //              surfaceHeight: DisplayUtils.getRealScreenHeight()
          //            })
        } else {
          this.aspRatio = Math.min(DEFAULT_ASPECT, this.videoAspRatio);
        }
      })
    },
    onVideoSizeChange: (w: number, h: number) => {
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
        XComponent({
          id: '' + new Date().getTime(),
          type: 'surface',
          libraryname: 'ijkplayer_napi',
          controller: this.componentController
        })
          .onLoad((context) => {
            Logger.e(this, 'XComponent onLoad')

            this.playerManager.init(context)
          })
          .onDestroy(() => {
            Logger.e(this, 'XComponent onDestroy')
          })
          .width('100%')
          .aspectRatio(this.videoAspRatio)

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