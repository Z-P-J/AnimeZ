import { getTheme } from '../utils/Themes';
import { SettingsContainer } from './Settings';
import { SettingGroup } from './Settings';
import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import SQLite from '../db/SQLite';
import Logger from '../utils/Logger';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import ImmersionBarSpace from './ImmersionBarSpace';
import { Recommend } from './home/Recommend';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * 我的页面
 */
@Component
export struct MyPage {
  @StorageLink('theme') theme: number = 0
  @State items: VideoHistoryInfo[] = [
      {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
        episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0},
      {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
        episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0},
      {link: 'link', title: 'title', currentTime: 10000, totalTime: 200000, coverUrl: '', episodeListIndex: 0,
        episodeIndex: 0, episodeName: '第一集', videoUrl: '', videoProgress: 0}
  ]
  //  @State yOffset: number = 0
  //  @State bgScale: number = 1
  @State bgHeight: number = 0
  private readonly scroller = new Scroller()

  private settings: SettingGroup[] = [
    {
      title: '更多',
      settings: [
        { title: 'Github主页', info: 'https://github.com/Z-P-J', icon: $r('app.media.ic_github'),
          onClick: () => {
            promptAction.showToast({message: 'TODO 打开Github主页'})
          }
        },
        { title: '免责声明', icon: $r('app.media.ic_gitee'),
          onClick: () => {
            promptAction.showToast({message: 'TODO 免责声明'})
          }
        },
        { title: '设置', icon: $r('app.media.ic_settings'),
          onClick: () => {
            router.pushUrl({ url: 'pages/SettingsPage' })
          }
        }
      ]
    }
  ]

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
        .brightness(this.theme == 0 ? 0.7 : 0.5)
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
            this.IconWithText($r('app.media.ic_star'), '我的收藏', () => {
              router.pushUrl({url: 'pages/VideoCollectionPage'})
            })
            this.IconWithText($r('app.media.ic_download'), '离线缓存', () => {
              router.pushUrl({ url: 'pages/DownloadManagerPage' })
            })
          }
          .padding(16)
          .backgroundColor(getTheme(this.theme).background_color)
          .borderRadius(16)
          .margin({ left: 16, right: 16 })
          .onAreaChange((_, newArea) => {
            this.bgHeight = parseInt(newArea.globalPosition.y.toString())
            + parseInt(newArea.height.toString()) / 2
          })

          this.HistoryList()

          this.More()

          Text('本应用仅供学习交流！')
            .fontSize(10)
            .margin({bottom: 16})

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
      .backgroundColor('#eeffffff')

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

      Image(this.theme == 0 ? $r("app.media.ic_theme_day") : $r("app.media.ic_theme_night"))
        .width(48)
        .height(36)
        .padding(6)
        .backgroundColor('#eeffffff')
        .borderRadius(10)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.theme = this.theme == 0 ? 1 : 0
//          router.pushUrl({ url: 'pages/SettingsPage' })
        })
    }
    .margin({ left: 16, right: 16, top: 56, bottom: 16 })
  }

  @Builder IconWithText(src: string | PixelMap | Resource, title: string, onClick?: (event?: ClickEvent) => void) {
    Row() {
      Image(src)
        .width(20)
        .height(20)
      Text(title)
        .fontSize(16)
        .fontColor(getTheme(this.theme).color_text_major)
        .margin({ left: 8 })
    }
    .onClick(onClick)
  }

  @Builder HistoryList() {
    Column() {
      Row() {
        Row()
          .height(14)
          .width(6)
          .margin({ right: 2 })
          .borderRadius(4)
          .backgroundColor(getTheme(this.theme).primary_color)
        Text('观看历史')
          .fontColor(getTheme(this.theme).color_text_major)
          .fontSize(16)
          .fontWeight(500)

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
            .height('100%')
            .aspectRatio(1)
          })
        }
        .listDirection(Axis.Horizontal)
        .padding({ left: 16, right: 16 })
        .width('100%')
        .aspectRatio(2.8)
      } else {
        Column() {
          Image($r('app.media.ic_empty'))
            .objectFit(ImageFit.Contain)
            .height(56)
            .width(56)
          Text('暂无记录').fontSize(14)
            .margin({top: 8})
            .fontColor(getTheme(this.theme).color_text_normal)
        }
        .padding({top: 16, bottom: 32})
        .width('100%')
      }
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
  }

  @Builder HistoryItem(item: VideoHistoryInfo) {
    Column() {
      Image(item.coverUrl)
        .alt($r('app.media.pic_load_failed'))
        .borderRadius(8)
        .borderWidth(1)
        .width('100%')
        .layoutWeight(1)
        .objectFit(ImageFit.Cover)
        .borderColor(getTheme(this.theme).background_color_dark)

      Text(item.title)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, bottom: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(getTheme(this.theme).color_text_minor)
        .fontSize(12)
    }
    .width('100%')
    .height('100%')
    .padding({top: 8, bottom: 8})
    .onClick(() => {
      router.pushUrl({url: 'pages/VideoDetailPage', params: {
        url: item.link,
        title: item.title,
        cover: item.coverUrl
      }})
    })
  }

  @Builder More() {
    Column() {
      ForEach(this.settings, (group, index) => {
        SettingsContainer({ group: group })
        if (index < this.settings.length - 1) {
          Blank().height(16)
        }
      })
    }
    .margin({left: 16, right: 16})
  }

}