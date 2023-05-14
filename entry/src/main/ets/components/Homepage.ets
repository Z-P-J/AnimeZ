import { CategoryPage } from './home/CategoryPage';
import ImmersionBarSpace from './ImmersionBarSpace';
import { Recommend } from './home/Recommend';
import router from '@ohos.router';

@Component
export struct Homepage {
  private readonly controller: TabsController = new TabsController();

  build() {
    Column() {
      ImmersionBarSpace()
        .backgroundColor(Color.White)
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
        .margin({ left: 12, right: 12 })
        .height(32)
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
        .borderRadius(32)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SearchPage' })
        })

        Image($r("app.media.ic_history"))
          .width(24)
          .height(24)
          .fillColor('#817977')
          .margin({ right: 16 })
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.pushUrl({ url: 'pages/VideoHistoryPage' })
          })
      }
      .height(56)
      .width('100%')
      .backgroundColor(Color.White)

      Recommend()

//      Tabs({
//        barPosition: BarPosition.Start,
//        controller: this.controller
//      }) {
//        TabContent() {
//          CategoryPage()
//        }
//        .size({ width: "100%", height: "100%" })
//        .tabBar("消息")
//
//        TabContent() {
//          CategoryPage()
//        }
//        .size({ width: "100%", height: "100%" })
//        .tabBar("联系人")
//
//        TabContent() {
//          CategoryPage()
//        }
//        .size({ width: "100%", height: "100%" })
//        .tabBar("动态")
//      }
//      .barWidth('100%')
//      .barMode(BarMode.Scrollable)

    }
    .width('100%')
    .height('100%')
  }
}