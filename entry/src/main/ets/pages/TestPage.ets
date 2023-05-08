import BimiAcgDataSource from '../api/impl/BimiAcgDataSource';
import { VideoPlayer } from '../player/VideoPlayer';
import { PlayerStatus } from '../player/PlayerStatus';
import Logger from '../utils/Logger';
import { PlayerManager } from '../player/PlayerManager';
import promptAction from '@ohos.promptAction';
import { PlayerController } from '../player/PlayerController'

@Entry
@Component
struct TestPage {
  @State message: string = 'Hello World'
  @State slideEnable: boolean = true;
  @State progressValue: number = 0;
  @State playStatus: number = PlayerStatus.INIT
  private playerManager: PlayerManager = new PlayerManager()

  aboutToAppear() {
    Logger.e(this, 'TestPage aboutToAppear playStatus=' + this.playStatus)
    let that = this;
    //    this.playerManager.addListener({
    //      onStatusChanged(status) {
    //        Logger.e(this, 'TestPage playStatus=' + this.playStatus)
    //        that.test(status)
    //      }
    //    })

    this.playerManager.addListener((status) => {
      this.playStatus = status
    })
    //    this.playerManager.play('https://ukzy.ukubf4.com/20230101/lQvUZ46s/index.m3u8')
    this.loading()

    new BimiAcgDataSource().parseVideoUrl('http://www.bimiacg4.net/bangumi/8552/play/1/1/')
      .then((url) => {
        this.message = url
        this.playerManager.play(url)
      })
  }

  build() {
    Column() {
      //      Stack({ alignContent: Alignment.Center }) {
      //        Row().width('100%').height('100%').backgroundColor(Color.Black)
      //
      //        if (this.playStatus == PlayerStatus.INIT || this.playStatus == PlayerStatus.LOADING) {
      //          LoadingProgress().width(48).height(48).color(Color.White)
      //        } else if (this.playStatus == PlayerStatus.ERROR) {
      //          Column() {
      //            Image($r('app.media.ic_refresh')).width(32).height(32).margin(8)
      //              .fillColor(Color.White).objectFit(ImageFit.Contain)
      //            Text('出错了...')
      //              .fontColor(Color.White)
      //              .fontSize(14)
      //          }
      //          .onClick(() => {
      //            this.loading()
      //          })
      //        } else {
      //          // Controller
      //          Column() {
      //            Row() {
      //              Image($r("app.media.ic_back"))
      //                .width(24)
      //                .height(24)
      //                .fillColor(Color.White)
      //                .margin({ left: 16 })
      //                .objectFit(ImageFit.Contain)
      //              Text('Title')
      //                .fontColor(Color.White)
      //                .fontSize(14)
      //                .fontWeight(500)
      //                .layoutWeight(1)
      //                .margin({ left: 16 })
      //                .align(Alignment.Start)
      //              Blank()
      //            }
      //            .height(56)
      //            .width('100%')
      //
      //
      //            Row() {
      //              Image(this.playStatus == PlayerStatus.PLAY ? $r("app.media.ic_pause") : $r("app.media.ic_play"))
      //                .width(24)
      //                .height(24)
      //                .fillColor(Color.White)
      //                .margin({ left: 16 })
      //                .objectFit(ImageFit.Contain)
      //                .onClick(() => {
      //                  if (this.playStatus == PlayerStatus.PLAY) {
      //                    this.playStatus = PlayerStatus.PAUSE
      //                  } else if (this.playStatus == PlayerStatus.PAUSE) {
      //                    this.playStatus = PlayerStatus.PLAY
      //                  }
      //                })
      //
      //              Text("00:10").fontSize(12).margin({ left: 16, right: 8 }).fontColor(Color.White)
      //              Slider({
      //                value: this.progressValue,
      //                min: 0,
      //                max: 100,
      //                step: 1,
      //                style: SliderStyle.OutSet
      //              })
      //                .layoutWeight(1)
      //                .blockColor(Color.Blue)
      //                .trackColor(Color.White)
      //                .selectedColor(Color.Blue)
      //                .showSteps(true)
      //                .showTips(true)
      //                .enabled(this.slideEnable)
      //                .onChange((value: number, mode: SliderChangeMode) => {
      //
      //                })
      //              Text('10:00').fontSize(12).margin({ left: 8, right: 16 }).fontColor(Color.White)
      //              Image($r("app.media.ic_fullscreen_enter"))
      //                .width(24)
      //                .height(24)
      //                .fillColor(Color.White)
      //                .margin({ right: 16 })
      //                .objectFit(ImageFit.Contain)
      //                .onClick(() => {
      //                  promptAction.showToast({message: 'TODO 全屏'})
      //                })
      //            }
      //            .padding({ top: 8, bottom: 8 })
      //            .width('100%')
      //          }
      //          .justifyContent(FlexAlign.SpaceBetween)
      //          .width('100%')
      //          .height('100%')
      //        }
      //      }
      //      .width('100%')
      //      .height('28%')


      VideoPlayer({ playerManager: this.playerManager })
        .width('100%')
//        .height('28%')


      Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        Button('重置').margin(8)
          .onClick(() => {
            this.playStatus = PlayerStatus.INIT
          })

        Button('加载').margin(8)
          .onClick(() => {
            this.loading()
          })

        Button('暂停').margin(8)
          .onClick(() => {
            this.playerManager.pause()
            //            this.playStatus = PlayerStatus.PAUSE
          })

        Button('播放').margin(8)
          .onClick(() => {
            this.playerManager.start()
            //            this.playStatus = PlayerStatus.PLAY
          })
        Button('错误').margin(8)
          .onClick(() => {
            this.playStatus = PlayerStatus.ERROR
          })
      }

      Text(this.message).fontSize(18).padding(20).fontWeight(FontWeight.Bold).layoutWeight(1)

    }
    .width('100%')
    .height('100%')
  }

  private loading() {
    this.playStatus = PlayerStatus.LOADING
    setTimeout(() => {
      this.playStatus = PlayerStatus.PLAY
    }, 1000)
  }
}