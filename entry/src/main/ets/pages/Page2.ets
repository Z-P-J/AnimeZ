import TransitionHelper from '../utils/TransitionHelper';
import router from '@ohos.router';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { PlayerStatus } from '../player/PlayerStatus';
import Logger from '../utils/Logger';

@Entry
@Component
struct Page2 {
  @State message: string = 'Hello World'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  aboutToAppear() {
  }

  pageTransition() {
    PageTransitionEnter(TransitionHelper.OPTIONS_TRANSITION_PUSH)
      .slide(SlideEffect.Right)

    PageTransitionEnter(TransitionHelper.OPTIONS_TRANSITION_POP)
      .slide(SlideEffect.Left)

    PageTransitionExit(TransitionHelper.OPTIONS_TRANSITION_PUSH)
      .slide(SlideEffect.Left)

    PageTransitionExit(TransitionHelper.OPTIONS_TRANSITION_POP)
      .slide(SlideEffect.Right)
  }

  build() {
    Scroll() {
      Column({space: 16}) {
        ImmersionBarSpace()
        Row() {
          Image($r("app.media.ic_anime"))
            .width(56)
            .height(56)
            .objectFit(ImageFit.Contain)

          Column() {
            Text($r('app.string.app_name'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_text_major'))
              .fontSize(16)
              .alignSelf(ItemAlign.Start)

            Text($r('app.string.module_desc'))
              .fontColor($r('app.color.color_text_minor'))
              .fontSize(14)
              .margin({top: 8})
              .alignSelf(ItemAlign.Start)
          }
          .margin({left: 8, right: 8})
          .layoutWeight(1)

          Image($r("app.media.ic_settings"))
            .width(24)
            .height(24)
            .fillColor('#817977')
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              router.pushUrl({url: 'pages/SettingsPage'})
            })
        }
        .padding(16)
        .backgroundColor($r('app.color.background_color'))
        .borderRadius(16)
        .margin({left: 16, right: 16})

        Row() {
          Text('本应用仅供学习交流')
            .fontColor(Color.White)
        }
        .width('90%')
        .height(32)
        .margin({left: 16, right: 16})
        .borderRadius(16)
        .linearGradient({
          angle: 135,
          colors: [[0xffff00, 0.0], [0xff0000, 1.0]]
        })

        Flex({justifyContent: FlexAlign.SpaceAround}) {

          this.IconWithText($r('app.media.ic_star'), '我的收藏')

          this.IconWithText($r('app.media.ic_download'), '离线缓存')

        }
        .padding(16)
        .backgroundColor($r('app.color.background_color'))
        .borderRadius(16)
        .margin({left: 16, right: 16})

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
          .width('100%')
          .onClick(() => {
            // TODO
          })

          Row({space: 8}) {
            // TODO
            this.HistoryItem()
            this.HistoryItem()
            this.HistoryItem()
          }
          .margin({top: 8})
          .width('100%')
        }
        .padding(16)
        .backgroundColor($r('app.color.background_color'))
        .borderRadius(16)
        .margin({left: 16, right: 16})

      }
      .width('100%')
      .constraintSize({
        minHeight: '100%'
      })

    }
    .backgroundColor('#fbfbfb')
    .width('100%')
    .height('100%')
  }

  @Builder IconWithText(src: string | PixelMap | Resource, title: string) {
    Row() {

      Image(src)
        .width(20)
        .height(20)

      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.color_text_major'))
        .margin({left: 8})

    }
  }

  @Builder HistoryItem() {
    Column() {
      Image($r('app.media.pic_load_failed'))
        .width('30%')
        .aspectRatio(1.68)
        .borderRadius(4)
        .borderColor('#cccccc')

      Text('Title')
        .alignSelf(ItemAlign.Start)
        .margin({top: 8})
        .fontColor($r('app.color.color_text_minor'))
    }
  }


}