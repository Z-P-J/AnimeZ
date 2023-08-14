import promptAction from '@ohos.promptAction';
import { getTheme } from '../utils/Themes';
import { CategoryPage } from './home/CategoryPage';
import ImmersionBarSpace from './ImmersionBarSpace';
import { Recommend } from './home/Recommend';
import router from '@ohos.router';

@Component
export struct Homepage {
  @StorageLink('theme') theme: number = 0

  build() {
    Column() {
      ImmersionBarSpace()
        .backgroundColor(getTheme(this.theme).background_color)
      Row() {
        Image($r("app.media.ic_anime"))
          .width(28)
          .height(28)
          .margin({ left: 16 })
          .objectFit(ImageFit.Contain)

        Row() {
          Image($r("app.media.ic_search2"))
            .width(16)
            .height(16)
            .margin({ left: 12, right: 8 })
            .fillColor('#817977')
            .objectFit(ImageFit.Contain)

          Text("番剧搜索")
            .fontWeight(300)
            .fontColor('#817977')
            .fontSize(14)
        }
        .margin({ left: 16, right: 16 })
        .height(32)
        .layoutWeight(1)
        .backgroundColor(getTheme(this.theme).background_color_accent)
        .borderRadius(32)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SearchPage' })
        })

        Image($r("app.media.ic_download_manager"))
          .width(20)
          .height(20)
          .fillColor('#817977')
          .margin({ right: 16 })
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DownloadManagerPage' })
          })

        Image($r("app.media.ic_history2"))
          .width(20)
          .height(20)
          .fillColor('#817977')
          .margin({ right: 16 })
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.pushUrl({ url: 'pages/VideoHistoryPage' })
          })
      }
      .height(56)
      .width('100%')
      .backgroundColor(getTheme(this.theme).background_color)

      Recommend()
    }
    .width('100%')
    .height('100%')
  }
}