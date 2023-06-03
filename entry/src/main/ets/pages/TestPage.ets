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
  @State isFullScreen: boolean = false
  @State rightPanelScale: number = 0
  @State progressRatio: number = 0

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
        this.playerManager.setPlayerUrl(url)
        this.playerManager.start()
      })
  }

  build() {
    Column() {


      Stack({ alignContent: Alignment.Center }) {


        Row() {
          if (this.isFullScreen) {
            Column() {
              //              Text('1111111')
              Scroll() {
                Column() {
                  //                  ForEach(['0.5', '0.75', '1.0', '1.25', '1.5', '1.75', '2.0', '2.5', '3.0'], (speed) => {
                  //                    Text(speed)
                  //                      .padding(8)
                  //                      .fontColor(Color.Black)
                  //                  })

                  Text('播放器')
                    .alignSelf(ItemAlign.Start)
                    .fontSize(this.isFullScreen ? 16 : 14)
                    .fontColor(Color.White)

                  Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceAround, wrap: FlexWrap.Wrap }) {
                    ForEach(['IjkPlayer', '系统内置'], (item) => {
                      Text(item)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(10)
                        .padding({ top: 12, bottom: 12 })
                        .borderRadius(6)
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
                  .margin({ top: 8 })

                  Text('画面尺寸')
                    .alignSelf(ItemAlign.Start)
                    .fontSize(this.isFullScreen ? 16 : 14)
                    .fontColor(Color.White)

                  Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceAround, wrap: FlexWrap.Wrap }) {
                    ForEach(['适应', '拉伸', '填充', '16:9', '4:3', '1:1'], (item) => {
                      Text(item)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .fontSize(10)
                        .padding({ top: 12, bottom: 12 })
                        .borderRadius(6)
                        .margin({ bottom: 8 })
                        .constraintSize({
                          minWidth: '33%'
                        })
                        .maxLines(1)
                        .onClick(() => {
                          promptAction.showToast({ message: 'TODO 更改画面尺寸' })
                        })
                    })
                  }
                  .margin({ top: 8 })

                }
              }
              .width('100%')
              .height('100%')
            }
            .alignSelf(ItemAlign.End)
            .backgroundColor(Color.Gray)
            .scale({ x: this.rightPanelScale, centerX: '100%' })
            .width('30%')
            .height('100%')
          }
        }
        .justifyContent(FlexAlign.End)
        .width('100%')
        .height('100%')

      }
      .backgroundColor(Color.Black)
      .width('100%')
      .aspectRatio(1.9)

      VideoPlayer({ playerManager: this.playerManager })
        .width('100%')
      //        .height('28%')


      Button('test')
        .onClick(() => {
          //          this.isFullScreen = !this.isFullScreen


          if (this.isFullScreen) {
            animateTo(
              {
                duration: 320, // 动画时长
                curve: Curve.Ease, // 动画曲线
                iterations: 1, // 播放次数
                playMode: PlayMode.Normal, // 动画模式
                onFinish: () => {
                  this.isFullScreen = false
                }
              },
              () => {
                this.rightPanelScale = 0
              }
            )
          } else {
            this.rightPanelScale = 0
            this.isFullScreen = true
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


        })

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .backgroundColor($r('app.color.background_color_accent'))
          .width('100%')
          .height('100%')
          .scale({ x: this.progressRatio / 100, centerX: 0 })

        Row() {
          Image($r('app.media.icon'))
            .height('100%')
            .aspectRatio(1.5)
            .borderRadius(4)
            .margin({ left: 16, right: 16 })
            .objectFit(ImageFit.Cover)

          Column() {
            Text("TaskName")
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .align(Alignment.Start)
              .width('100%')

            Text('info')
              .fontSize(10)
              .align(Alignment.Start)
              .width('100%')
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)
          .height('100%')
          .margin({ right: 16 })

          Blank()
        }
        .width('100%')
        .height('100%')
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .height(80)
      .backgroundColor('#eeeeee')
      .onAppear(() => {
        let id = setInterval(() => {
          if (this.progressRatio >= 100) {
            clearInterval(id)
            return
          }
          animateTo({
            duration: 250,
            curve: Curve.ExtremeDeceleration,
            iterations: 1,
            playMode: PlayMode.Normal
          }, () => {
            this.progressRatio += 1
          })
        }, 1000)
      })

      //      Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
      //        Button('重置').margin(8)
      //          .onClick(() => {
      //            this.playStatus = PlayerStatus.INIT
      //          })
      //
      //        Button('加载').margin(8)
      //          .onClick(() => {
      //            this.loading()
      //          })
      //
      //        Button('暂停').margin(8)
      //          .onClick(() => {
      //            this.playerManager.pause()
      //            //            this.playStatus = PlayerStatus.PAUSE
      //          })
      //
      //        Button('播放').margin(8)
      //          .onClick(() => {
      //            this.playerManager.start()
      //            //            this.playStatus = PlayerStatus.PLAY
      //          })
      //        Button('错误').margin(8)
      //          .onClick(() => {
      //            this.playStatus = PlayerStatus.ERROR
      //          })
      //      }
      //
      //      Text(this.message).fontSize(18).padding(20).fontWeight(FontWeight.Bold).layoutWeight(1)

    }
    .width('100%')
    .height('100%')
  }

  private loading() {
    this.playStatus = PlayerStatus.BUFFERING
    setTimeout(() => {
      this.playStatus = PlayerStatus.PLAY
    }, 1000)
  }
}