import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import SQLite from '../db/SQLite';
import Logger from '../utils/Logger';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import ImmersionBarSpace from './ImmersionBarSpace';
import { Recommend } from './home/Recommend';
import router from '@ohos.router';

/**
 * 我的页面
 */
@Component
export struct MyPage {
  @State items: VideoHistoryInfo[] = [
  //    {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
  //      episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0},
  //    {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
  //      episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0},
  //    {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
  //      episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0}
  ]
  //  @State yOffset: number = 0
  //  @State bgScale: number = 1
  @State bgHeight: number = 0
  private readonly scroller = new Scroller()

  aboutToAppear() {
    SQLite.with(VideoHistoryTable)
      .queryAll()
      .then((items) => {
        this.items = items
      })
      .catch((e) => {
        Logger.e(this, 'queryAll error! ' + JSON.stringify(e))
      })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.bg_main_nav'))
        .width('100%')
        .brightness(0.7)
        .height(this.bgHeight)
          //        .translate({ y: -this.yOffset })
          //        .scale({x: this.bgScale, y: this.bgScale, centerY: 0})
        .objectFit(ImageFit.Cover)
      Scroll(this.scroller) {
        Column({ space: 16 }) {
          ImmersionBarSpace()
          this.Header()

          //          Row() {
          //            Text('本应用仅供学习交流')
          //              .fontColor(Color.White)
          //          }
          //          .width('90%')
          //          .height(32)
          //          .margin({ left: 16, right: 16 })
          //          .borderRadius(16)
          //          .linearGradient({
          //            angle: 135,
          //            colors: [[0xffff00, 0.0], [0xff0000, 1.0]]
          //          })

          Flex({ justifyContent: FlexAlign.SpaceAround }) {
            this.IconWithText($r('app.media.ic_star'), '我的收藏')
            this.IconWithText($r('app.media.ic_download'), '离线缓存')
          }
          .padding(16)
          .backgroundColor($r('app.color.background_color'))
          .borderRadius(16)
          .margin({ left: 16, right: 16 })
          .onAreaChange((_, newArea) => {
            this.bgHeight = parseInt(newArea.globalPosition.y.toString())
            + parseInt(newArea.height.toString()) / 2
          })

          Column() {
            Row() {
              Text('观看历史')
                .fontColor($r('app.color.color_text_major'))
                .fontSize(14)

              Blank()

              Image($r("app.media.ic_enter"))
                .width(24)
                .height(24)
                .fillColor('#817977')
                .objectFit(ImageFit.Contain)
            }
            .padding({ left: 16, top: 16, right: 16, bottom: 8 })
            .width('100%')
            .onClick(() => {
              router.pushUrl({ url: 'pages/VideoHistoryPage' })
            })

            if (this.items && this.items.length > 0) {
              List({ space: 8 }) {
                ForEach(this.items, (item) => {
                  ListItem() {
                    this.HistoryItem(item)
                  }
                })
              }
              .listDirection(Axis.Horizontal)
              .padding({ left: 16, right: 16 })
              .height(100)
              .width('100%')
            } else {
              Text('暂无记录').fontSize(16).fontColor($r('app.color.color_text_major')).height(100)
            }
          }
          .backgroundColor($r('app.color.background_color'))
          .borderRadius(16)
          .margin({ left: 16, right: 16 })

        }
        .width('100%')
        .constraintSize({
          minHeight: '100%'
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      //      .onScroll((x, y) => {
      //        Logger.e(this, 'x=' + x + ' y=' + y + ' offset=' + JSON.stringify(this.scroller.currentOffset()))
      //        let offset = this.scroller.currentOffset()
      //        if (offset.yOffset <= 0) {
      //          this.yOffset = offset.yOffset
      //
      ////          this.bgScale = -this.yOffset / this.bgHeight + 1
      //        }
      //      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder Header() {
    Row() {
      Stack() {
        Image($r("app.media.ic_anime"))
          .width(32)
          .height(32)
          .objectFit(ImageFit.Contain)
      }
      .width(56)
      .height(56)
      .borderWidth(1)
      .borderRadius(28)
      .borderColor('#eeeeee')
      .backgroundColor(Color.White)

      Column() {
        Text($r('app.string.app_name'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .fontSize(16)
          .alignSelf(ItemAlign.Start)

        Text($r('app.string.module_desc'))
          .fontColor('#eeeeee')
          .fontSize(12)
          .margin({ top: 8 })
          .alignSelf(ItemAlign.Start)
      }
      .margin({ left: 16, right: 16 })
      .layoutWeight(1)

      Image($r("app.media.ic_settings"))
        .width(36)
        .height(36)
        .fillColor('#817977')
        .padding(6)
        .backgroundColor('#eeffffff')
        .borderRadius(6)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' })
        })
    }
    .margin({ left: 16, right: 16, top: 56, bottom: 16 })
  }

  @Builder IconWithText(src: string | PixelMap | Resource, title: string) {
    Row() {
      Image(src)
        .width(20)
        .height(20)
      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.color_text_major'))
        .margin({ left: 8 })
    }
  }

  @Builder HistoryItem(item: VideoHistoryInfo) {
    Column() {
      Image(item.coverUrl)
        .alt($r('app.media.pic_load_failed'))
        .width('30%')
        .aspectRatio(1.4)
        .borderRadius(4)
        .borderColor('#cccccc')

      Text(item.title)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor($r('app.color.color_text_minor'))
    }
  }

}