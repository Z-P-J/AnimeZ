import DisplayUtils from '../utils/DisplayUtils';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { PlayerStatus } from './PlayerStatus';
import {PlayerController} from './PlayerController';
import { PlayerManager } from './PlayerManager';
import Logger from '../utils/Logger';

const DEFAULT_ASPECT = 1.9

/**
 * 视频播放器，封装IjkPlayer
 */
@Component
export struct VideoPlayer {
  @State videoAspRatio: number = DEFAULT_ASPECT
  @State aspRatio: number = DEFAULT_ASPECT
  @State playStatus: number = PlayerStatus.INIT;
  @State videoUrl: string = ''
  @State playerStatus: PlayerStatus = PlayerStatus.INIT
  @State isFullScreen: boolean = false

  private readonly componentController: XComponentController = new XComponentController()

  private playerManager: PlayerManager = null;
  private immersionStatusBar: boolean = false



  aboutToAppear() {
    if (this.playerManager) {
      this.playerManager.addListener((status) => {
        this.playerStatus = status;
      })
      this.playerManager.setVideoSizeChangedListener((w: number, h: number) => {
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
      })


      this.playerManager.addFullScreenChangeListener((isFullScreen) => {
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
      })

    } else {
      throw new Error('You must set playerManager firstly!')
    }
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

        PlayerController({playerManager: this.playerManager})
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