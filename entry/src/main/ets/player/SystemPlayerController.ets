import { PlayerStatus } from './IPlayerManager';
import IPlayerManager, { VideoFit, PlayerListener } from './IPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import VideoTimeUtils from './VideoTimeUtils';
import Logger from '../utils/Logger';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

interface KeyValue {
  name: string,
  value: number
}

const VIDEO_SPEED_LIST: KeyValue[] = [
  { name: '0.75', value: PlaybackSpeed.Speed_Forward_0_75_X },
  { name: '1.00', value: PlaybackSpeed.Speed_Forward_1_00_X },
  { name: '1.25', value: PlaybackSpeed.Speed_Forward_1_25_X },
  { name: '1.75', value: PlaybackSpeed.Speed_Forward_1_75_X },
  { name: '2.00', value: PlaybackSpeed.Speed_Forward_2_00_X },
]

const VIDEO_FIT_LIST: KeyValue[] = [
  { name: '适应', value: VideoFit.Contain }, { name: '拉伸', value: VideoFit.Cover },
  { name: '填充', value: VideoFit.Fill }, { name: '16:9', value: VideoFit.Fit_16_9 },
  { name: '4:3', value: VideoFit.Fit_4_3 }, { name: '1:1', value: VideoFit.Fit_1_1 },
]

enum PanelType {

  NONE = 0,
  SPEED = 1,
  EPISODES = 2,
  PLAYER_SETTINGS = 3

}

/**
 * 播放器控制界面
 * TODO 重构
 */
@Component
export struct SystemPlayerController {
  @State currentTime: string = "00:00";
  @State totalTime: string = "00:00";
  @State progress: number = 0;
  @State slideEnable: boolean = true;
  @State playerStatus: number = PlayerStatus.PLAY;
  @State showController: boolean = true;
  @State title: string = ''
  @State isFullScreen: boolean = false
  @State showPanel: boolean = false
  @State rightPanelScale: number = 0
  @State rightPanelType: number = PanelType.NONE
  @State currentSpeed: string = '1.00'
  @State isLocked: boolean = false
  @State videoFit: number = VideoFit.Contain
  private playerManager: IPlayerManager = null;
  private showControllerTimer: number = -1;
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status
      Logger.e(this, 'PlayerController status=' + status + " playerStatus=" + this.playerStatus)
    },
    onEpisodeChanged: (episode: EpisodeInfo) => {
      this.title = episode.desc
    },
    onVideoSpeedChanged: (videoSpeed: number) => {

    },
    onVideoFitChanged: (videoFit: VideoFit) => {
      this.videoFit = videoFit
    },
    onFullScreenChanged: (isFullScreen: boolean) => {
      this.isFullScreen = isFullScreen
    },
    onVideoSizeChange: (w: number, h: number) => {

    },
    onProgressChange: (totalTime: number, currentTime: number) => {
      this.setProgress(totalTime, currentTime)
    }
  }

  aboutToAppear() {
    this.playerStatus = PlayerStatus.INIT
    promptAction.showToast({ message: "PlayerController statusTest=" + this.playerStatus })
    if (this.playerManager) {
      this.playerStatus = this.playerManager.getStatus()
      this.playerManager.addListener(this.playerListener)
    } else {
      throw new Error('You must set playerManager firstly!')
    }
  }

  aboutToDisappear() {
    //    this.playerManager.destroy()
    this.playerManager.removeListener(this.playerListener)
    if (this.showControllerTimer >= 0) {
      clearTimeout(this.showControllerTimer)
      this.showControllerTimer = -1;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {

      this.Loading()

      Column() {
        Image($r('app.media.ic_refresh'))
          .width(32)
          .height(32)
          .margin(8)
          .fillColor(Color.White)
          .objectFit(ImageFit.Contain)
        Text('出错了...')
          .fontColor(Color.White)
          .fontSize(14)
      }
      .visibility(this.playerStatus === PlayerStatus.ERROR ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.playerManager.start()
      })

      Column() {
        Image($r('app.media.ic_refresh'))
          .width(32)
          .height(32)
          .margin(8)
          .fillColor(Color.White)
          .objectFit(ImageFit.Contain)
        Text('重新播放')
          .fontColor(Color.White)
          .fontSize(14)
      }
      .visibility(this.playerStatus === PlayerStatus.DONE ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.playerManager.stop()
        this.playerManager.start()
      })

      if (this.showController) {
        // Controller
        this.VideoController()
      }

      this.RightPanel()
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.showController = !this.showController;
    })
  }

  @Builder Loading() {
    Stack({ alignContent: Alignment.Center }) {
      LoadingProgress().width(48).height(48).color(Color.White)
        .visibility(
            this.playerStatus === PlayerStatus.INIT || this.playerStatus === PlayerStatus.BUFFERING
            ? Visibility.Visible : Visibility.None
        )
    }
    .visibility(
        this.playerStatus === PlayerStatus.INIT || this.playerStatus === PlayerStatus.BUFFERING
        ? Visibility.Visible : Visibility.None
    )
    .backgroundColor('#80000000')
    .borderRadius(16)
    .width('100%')
    .height('100%')
  }

  @Builder VideoController() {
    Stack() {
      Column() {
        Row() {
          Image($r("app.media.ic_arrow_left"))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .margin({ left: this.isFullScreen ? 20 : 14 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              if (this.playerManager.isFullScreen()) {
                this.playerManager.exitFullScreen()
                return
              }
              router.back()
            })
          Text(this.title)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(500)
            .layoutWeight(1)
            .margin({ left: 16 })
            .align(Alignment.Start)
          Blank()


          if (this.isFullScreen) {
            Image($r("app.media.ic_airplay"))
              .width(24)
              .height(24)
              .fillColor(Color.White)
              .margin({ left: 24 })
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                promptAction.showToast({ message: 'TODO 投屏' })
              })
          }
          Image($r("app.media.ic_float_window"))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .margin({ left: this.isFullScreen ? 24 : 16 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              promptAction.showToast({ message: 'TODO 小窗播放' })
            })
          Image($r("app.media.ic_setting"))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .margin({ left: this.isFullScreen ? 24 : 16, right: this.isFullScreen ? 24 : 16 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.showRightPanel(PanelType.PLAYER_SETTINGS)
            })
        }
        .width('100%')
        .padding({ top: this.isFullScreen ? 16 : 4 })
        .visibility(this.isLocked ? Visibility.Hidden : Visibility.Visible)
        .linearGradient({
          angle: 180,
          colors: [['#000000', 0.0], ['#80000000', 0.5], ['#00000000', 1.0]]
        })

        if (this.isFullScreen) {
          Image(this.isLocked ? $r('app.media.ic_lock') : $r('app.media.ic_unlock'))
            .width(44)
            .height(44)
            .padding(12)
            .margin({ left: 16 })
            .backgroundColor('#80000000')
            .fillColor(Color.White)
            .borderRadius(28)
            .alignSelf(ItemAlign.Start)
            .onClick(() => {
              this.isLocked = !this.isLocked
            })
        }

        Row() {
          Image((this.playerStatus == PlayerStatus.PLAY || this.playerStatus == PlayerStatus.BUFFERING) ? $r("app.media.ic_pause") : $r("app.media.ic_play"))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .margin({ left: this.isFullScreen ? 16 : 12 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              promptAction.showToast({ message: 'status=' + this.playerStatus })
              if (this.playerStatus == PlayerStatus.PLAY || this.playerStatus == PlayerStatus.BUFFERING) {
                this.playerManager.pause()
              } else {
                this.playerManager.start()
              }
            })

          Text(this.currentTime).fontSize(12).margin({ left: 12, right: 6 }).fontColor(Color.White)
          Slider({
            value: this.progress,
            min: 0,
            max: 100,
            step: 1,
            style: SliderStyle.OutSet
          })
            .layoutWeight(1)
            .blockColor($r('app.color.primary_color_accent'))
            .trackColor(Color.White)
            .trackThickness(2)
            .selectedColor($r('app.color.primary_color'))
              //                .showSteps(true)
              //                .showTips(true)
            .enabled(this.slideEnable)
            .onChange((value: number, mode: SliderChangeMode) => {
              Logger.e(this, 'Slider onChange mode=' + mode + ' value=' + value + ' typeof mode=' + (typeof mode)
              + ' result=' + (mode == SliderChangeMode.End || mode == SliderChangeMode.Click)
              + ' result2=' + (mode == SliderChangeMode.Click) + ' click=' + SliderChangeMode.Click + ' result3=' + (mode === SliderChangeMode.Click))
              if (mode == SliderChangeMode.End || mode == 3) {
                this.progress = value
                let seekValue = value / 100 * this.playerManager.getDuration();
                Logger.e(this, 'Slider onChange seekValue=' + seekValue + " duration=" + this.playerManager.getDuration())

                this.setProgress(this.playerManager.getDuration(), seekValue)

                this.playerManager.seekTo(seekValue);
              }
            })
          Text(this.totalTime).fontSize(12).margin({ left: 6, right: 12 }).fontColor(Color.White)

          Text(`${this.currentSpeed}X`)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderWidth(1)
            .borderColor(Color.White)
            .borderRadius(4)
            .margin({ right: 12 })
            .fontSize(12)
            .fontColor(Color.White)
            .onClick(() => {
              this.showRightPanel(PanelType.SPEED)
            })

          if (this.isFullScreen) {
            Text('选集')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderWidth(1)
              .borderColor(Color.White)
              .borderRadius(4)
              .margin({ right: 12 })
              .fontSize(12)
              .fontColor(Color.White)
              .onClick(() => {
                this.showRightPanel(PanelType.EPISODES)
              })
          } else {
            Image($r("app.media.ic_fullscreen_enter"))
              .width(24)
              .height(24)
              .fillColor(Color.White)
              .margin({ right: 12 })
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                promptAction.showToast({ message: 'TODO 全屏' })
                this.playerManager.enterFullScreen()
              })
          }
        }
        .padding({ top: this.isFullScreen ? 10 : 4, bottom: this.isFullScreen ? 10 : 4 })
        .width('100%')
        .visibility(this.isLocked ? Visibility.Hidden : Visibility.Visible)
        .linearGradient({
          angle: 180,
          colors: [['#00000000', 0.0], ['#80000000', 0.5], ['#ff000000', 1.0]]
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      if (this.showController) {
        this.showControllerTimer = setTimeout(() => {
          // 5s后隐藏
          this.showController = false
          this.showControllerTimer = -1
        }, 6000)
      }
    })
    .onDisAppear(() => {
      if (this.showControllerTimer >= 0) {
        clearTimeout(this.showControllerTimer)
        this.showControllerTimer = -1
      }
    })
  }

  @Builder RightPanel() {
    Row() {
      if (this.showPanel) {
        if (this.rightPanelType == PanelType.SPEED) {
          this.ChangeSpeedPanel()
        } else if (this.rightPanelType == PanelType.EPISODES) {
          this.EpisodeList()
        } else if (this.rightPanelType == PanelType.PLAYER_SETTINGS) {
          this.PlayerSettings()
        }
      }
    }
    .justifyContent(FlexAlign.End)
    .hitTestBehavior(this.showPanel ? HitTestMode.Default : HitTestMode.None)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.hideRightPanel()
    })
  }

  @Builder ChangeSpeedPanel() {
    Scroll() {
      Column({ space: this.isFullScreen ? 16 : 8 }) {

        ForEach(VIDEO_SPEED_LIST, (item: KeyValue) => {
          Text(`${item.name}X`)
            .padding(8)
            .fontSize(this.isFullScreen ? 14 : 12)
            .fontColor(Color.White)
            .width('100%')
            .backgroundColor(this.currentSpeed == item.name ? $r('app.color.primary_color_accent') : Color.Transparent)
            .borderRadius(6)
            .borderColor(Color.White)
            .borderWidth(this.currentSpeed == item.name ? 0 : 1)
            .onClick(() => {
              this.currentSpeed = item.name
              this.playerManager.setSpeed(item.value)
            })
        })

      }
      .padding(this.isFullScreen ? 16 : 8)
      .width('100%')
      .constraintSize({
        minHeight: '100%'
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
    .width(this.isFullScreen ? '30%' : '45%')
    .scale({ x: this.rightPanelScale, centerX: '100%' })
    .backgroundColor('#80000000')
  }

  @Builder EpisodeList() {
    Scroll() {
      Column({ space: this.isFullScreen ? 16 : 8 }) {

        Row() {

          Text('选集')
            .fontSize(this.isFullScreen ? 16 : 14)
            .fontColor(Color.White)

          Text('正序')
            .margin({ left: 24 })
            .fontSize(this.isFullScreen ? 12 : 10)
            .fontColor(Color.White)

        }
        .width('100%')

        //  TODO
        if (this.playerManager.getEpisode()) {
          Text(this.playerManager.getEpisode().title)
            .padding(8)
            .fontSize(this.isFullScreen ? 14 : 12)
            .fontColor(Color.White)
            .width('100%')
            .backgroundColor($r('app.color.primary_color_accent'))
            .borderRadius(6)
            .borderColor(Color.White)
            .borderWidth(0)
            .onClick(() => {
              // TODO
            })
        }
      }
      .padding(this.isFullScreen ? 16 : 8)
      .width('100%')
      .constraintSize({
        minHeight: '100%'
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
    .width(this.isFullScreen ? '30%' : '45%')
    .scale({ x: this.rightPanelScale, centerX: '100%' })
    .backgroundColor('#80000000')
  }

  @Builder PlayerSettings() {
    Scroll() {
      Column({ space: this.isFullScreen ? 16 : 8 }) {

        Text('播放器')
          .alignSelf(ItemAlign.Start)
          .fontSize(this.isFullScreen ? 16 : 13)
          .fontColor(Color.White)

        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceAround, wrap: FlexWrap.Wrap }) {
          ForEach(['系统内置', 'IjkPlayer'], (item, i) => {
            Text(item)
              .textAlign(TextAlign.Center)
              .fontColor(Color.White)
              .fontSize(this.isFullScreen ? 14 : 11)
              .padding(6)
              .backgroundColor(i == 0 ? $r('app.color.primary_color_accent') : Color.Transparent)
              .borderRadius(4)
              .margin({ bottom: 8 })
              .constraintSize({
                minWidth: '40%'
              })
              .maxLines(1)
              .onClick(() => {
                promptAction.showToast({ message: 'TODO 播放器' })
              })
          })
        }
        .width('100%')

        Text('画面尺寸')
          .alignSelf(ItemAlign.Start)
          .fontSize(this.isFullScreen ? 16 : 13)
          .fontColor(Color.White)

        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceAround, wrap: FlexWrap.Wrap }) {
          ForEach(VIDEO_FIT_LIST, (item: KeyValue) => {
            Text(item.name)
              .textAlign(TextAlign.Center)
              .fontColor(Color.White)
              .fontSize(this.isFullScreen ? 14 : 11)
              .padding(6)
              .backgroundColor((this.videoFit == item.value) ? $r('app.color.primary_color_accent') : Color.Transparent)
              .borderRadius(4)
              .margin({ bottom: 8 })
              .width('33%')
                //              .constraintSize({
                //                minWidth: '33%'
                //              })
              .maxLines(1)
              .onClick(() => {
                this.playerManager.setVideoFit(item.value)
              })
          })
        }
        .width('100%')

      }
      .padding(this.isFullScreen ? 16 : 8)
      .width('100%')
      .constraintSize({
        minHeight: '100%'
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
    .width(this.isFullScreen ? '30%' : '45%')
    .scale({ x: this.rightPanelScale, centerX: '100%' })
    .backgroundColor('#80000000')
  }

  private showRightPanel(type: number) {
    this.rightPanelType = type
    this.rightPanelScale = 0
    this.showPanel = true
    this.showController = false
    if (this.showControllerTimer >= 0) {
      clearTimeout(this.showControllerTimer)
    }
    animateTo(
      {
        duration: 320, // 动画时长
        curve: Curve.Ease,
        iterations: 1, // 播放次数
        playMode: PlayMode.Normal, // 动画模式
        onFinish: () => {
        }
      },
      () => {
        this.rightPanelScale = 1
      }
    )
  }

  private hideRightPanel() {
    animateTo(
      {
        duration: 320, // 动画时长
        curve: Curve.Ease, // 动画曲线
        iterations: 1, // 播放次数
        playMode: PlayMode.Normal, // 动画模式
        onFinish: () => {
          this.showPanel = false
          this.showController = true
          this.rightPanelType = PanelType.NONE
        }
      },
      () => {
        this.rightPanelScale = 0
      }
    )
  }

  private setProgress(duration: number, position: number) {
    let pos = 0;
    if (duration > 0) {
      this.slideEnable = true;
      let curPercent = position / duration;
      pos = curPercent * 100;
      this.progress = pos;
    }
    Logger.e(this, "setProgress position:" + position + ",duration:" + duration + ",progressValue:" + pos);
    this.totalTime = VideoTimeUtils.stringForTime(duration);
    if (position > duration) {
      position = duration;
    }
    this.currentTime = VideoTimeUtils.stringForTime(position);
  }
}