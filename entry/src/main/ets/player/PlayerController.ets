import VideoTimeUtils from './VideoTimeUtils';
import { PlayerStatus } from './PlayerStatus';
import Logger from '../utils/Logger';
import { PlayerManager } from './PlayerManager';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import VideoInfo from '../entity/VideoInfo';

@Component
export struct PlayerController {
  @State currentTime: string = "00:00";
  @State totalTime: string = "00:00";
  @State progress: number = 0;
  @State slideEnable: boolean = true;
  @State playerStatus: number = PlayerStatus.INIT;
  @State showController: boolean = true;
  @State title: string = ''

  private playerManager: PlayerManager = null;
//  private updateProgressTimer: number = -1;
  private showControllerTimer: number = -1;

  aboutToAppear() {
    this.playerStatus = PlayerStatus.INIT
    promptAction.showToast({message: "PlayerController statusTest=" + this.playerStatus})
    if (this.playerManager) {
      this.playerStatus = this.playerManager.getStatus()
      this.playerManager.addListener((status) => {
        this.playerStatus = status;
        Logger.e(this, 'PlayerController status=' + status + " that.status=" + this.playerStatus)
//        if (status == PlayerStatus.PLAY) {
//          this.startProgress()
//        } else {
//          this.stopProgress()
//        }
      })
      this.playerManager.addProgressListener((totalTime, currentTime) => {
        this.setProgress(totalTime, currentTime)
      })
      this.playerManager.setEpisodeChangeListener((episode) => {
        this.title = episode.desc
      })
    } else {
      throw new Error('You must set playerManager firstly!')
    }
  }

  aboutToDisappear() {
    this.playerManager.destroy()
    if (this.showControllerTimer >= 0) {
      clearTimeout(this.showControllerTimer)
      this.showControllerTimer = -1;
    }
  }

  onPageShow() {
    promptAction.showToast({message: 'PlayerController onPageShow'})
  }

  onPageHide() {
    promptAction.showToast({message: 'PlayerController onPageHide'})
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.playerStatus == PlayerStatus.INIT || this.playerStatus == PlayerStatus.LOADING || this.playerStatus == PlayerStatus.BUFFERING) {
        Stack({ alignContent: Alignment.Center }){
          LoadingProgress().width(48).height(48).color(Color.White)
        }
        .backgroundColor('#90666666')
        .borderRadius(16)
        .padding({left: 32, top: 16, right: 32, bottom: 16})
      } else if (this.playerStatus == PlayerStatus.ERROR) {
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
        .onClick(() => {
          this.playerManager.start()
        })
      } else if (this.playerStatus == PlayerStatus.DONE) {
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
        .onClick(() => {
          this.playerManager.start()
        })
      } else {
        if (this.showController) {
          // Controller
          Column() {
            Row() {
              Image($r("app.media.ic_back"))
                .width(24)
                .height(24)
                .fillColor(Color.White)
                .margin({ left: 16 })
                .objectFit(ImageFit.Contain)
                .onClick(() => {
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
            }
            .height(56)
            .width('100%')

            Row() {
              Image(this.playerStatus == PlayerStatus.PLAY ? $r("app.media.ic_pause") : $r("app.media.ic_play"))
                .width(24)
                .height(24)
                .fillColor(Color.White)
                .margin({ left: 16 })
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                  promptAction.showToast({message: 'status=' + this.playerStatus})
                  if (this.playerStatus == PlayerStatus.PLAY) {
                    this.playerManager.pause()
                  } else if (this.playerStatus == PlayerStatus.PAUSE) {
                    this.playerManager.start()
                  }
                })

              Text(this.currentTime).fontSize(12).margin({ left: 16, right: 8 }).fontColor(Color.White)
              Slider({ value: this.progress, min: 0, max: 100, step: 1, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor($r('app.color.primary_color_accent'))
                .trackColor(Color.White)
                .selectedColor($r('app.color.primary_color'))
                .showSteps(true)
                .showTips(true)
                .enabled(this.slideEnable)
                .onChange((value: number, mode: SliderChangeMode) => {
                  if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                    this.progress = value / 100
                    let seekValue = this.progress * this.playerManager.getDuration();
                    Logger.e(this, 'Slider onChange seekValue=' + seekValue + " duration=" + this.playerManager.getDuration())
                    this.playerManager.seekTo(seekValue + "");
                  }
                })
              Text(this.totalTime).fontSize(12).margin({ left: 8, right: 16 }).fontColor(Color.White)
              Image($r("app.media.ic_fullscreen_enter"))
                .width(24)
                .height(24)
                .fillColor(Color.White)
                .margin({ right: 16 })
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                  promptAction.showToast({ message: 'TODO 全屏' })
                })
            }
            .padding({ top: 4, bottom: 4 })
            .width('100%')
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .height('100%')
          .onAppear(() => {
            if (this.showController) {
              this.showControllerTimer = setTimeout(() => {
                // 5s后隐藏
                this.showController = false
                this.showControllerTimer = -1
              }, 5000)
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      promptAction.showToast({message: 'playerStatus=' + this.playerStatus})
      if (this.playerStatus == PlayerStatus.PLAY || this.playerStatus == PlayerStatus.PAUSE) {
        this.showController = !this.showController;
        promptAction.showToast({message: 'showController=' + this.showController})
      }
    })
  }



//  private startProgress() {
//    this.stopProgress()
//    this.updateProgressTimer = setInterval(() => {
//      if (this.updateProgressTimer < 0) {
//        return
//      }
//      this.setProgress();
//    }, 1000);
//    Logger.e(this, 'startProgress updateProgressTimer=' + this.updateProgressTimer)
//  }
//
//  private stopProgress() {
//    if (this.updateProgressTimer < 0) {
//      return
//    }
//    let timer = this.updateProgressTimer;
//    this.updateProgressTimer = -1
//    clearInterval(timer)
//  }


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