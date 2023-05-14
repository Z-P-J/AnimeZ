import TransitionHelper from '../utils/TransitionHelper';
import { MyPage } from '../components/MyPage';
import { Homepage } from '../components/Homepage';
import ImmersionBarSpace from '../components/ImmersionBarSpace';

@Entry
@Component
struct Index {
  //  @State message: string = 'Hello World11111111'
  //  @State videoList: VideoInfo[] = []
  //  private hasMore: boolean
  //  private currentPage: number = 1
  //  @State state: number = ViewState.CUSTOM
  //  @State errorMessage: string = ''
  //
  //  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiAcgDataSource()

  @State message: string = 'Hello World'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  //  aboutToAppear() {
  //    this.loadNextPage()
  //  }

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
    //    Column() {
    //      ImmersionBarSpace()
    //      Row() {
    //        Image($r("app.media.ic_anime"))
    //          .width(24)
    //          .height(24)
    //          .margin({ left: 16 })
    //          .objectFit(ImageFit.Contain)
    //
    //        Row() {
    //          Image($r("app.media.ic_search2"))
    //            .width(16)
    //            .height(16)
    //            .margin({ left: 12, right: 8 })
    //            .fillColor('#817977')
    //            .objectFit(ImageFit.Contain)
    //
    //          Text("搜索番剧")
    //            .fontWeight(300)
    //            .fontColor('#817977')
    //            .fontSize(14)
    //        }
    //        .margin({left: 12, right: 12})
    //        .height(32)
    //        .layoutWeight(1)
    //        .backgroundColor('#f5f5f5')
    //        .borderRadius(32)
    //        .onClick(() => {
    //          router.pushUrl({url: 'pages/SearchPage'})
    //        })
    //
    //        Image($r("app.media.ic_history"))
    //          .width(24)
    //          .height(24)
    //          .fillColor('#817977')
    //          .margin({right: 16})
    //          .objectFit(ImageFit.Contain)
    //      }
    //      .height(56)
    //      .width('100%')
    //
    //      StateView(
    //        {
    //          state: $state,
    //          errorMessage: $errorMessage,
    //          content: () => {
    //            VideoList({ videoList: this.videoList }).layoutWeight(1).padding(16)
    //          },
    //          custom: null,
    //          onRetry: () => {
    //            this.loadNextPage()
    //            return true;
    //          }
    //        }
    //      )
    //        .width('100%')
    //        .layoutWeight(1)
    //      ImmersionBarSpace()
    //    }
    //    .width('100%')
    //    .height('100%')

    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          Homepage()
        }
        .tabBar(this.TabBarBuilder(0, '首页', $r('app.media.ic_homepage'), $r('app.media.ic_homepage_selected')))

        TabContent() {
          MyPage()
        }
        .tabBar(this.TabBarBuilder(1, '我的', $r('app.media.ic_me'), $r('app.media.ic_me_selected')))
      }
      .vertical(false)
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(48)
      .backgroundColor($r('app.color.background_color_accent'))
//      .animationDuration(420)
      .onChange((index: number) => {
        this.currentIndex = index
      })

      ImmersionBarSpace()
    }
    .backgroundColor($r('app.color.background_color'))
    .width('100%')
    .height('100%')
  }

  @Builder TabBarBuilder(index: number, title: string, icon: Resource, iconSelected: Resource) {
    Column() {
      Image(this.currentIndex === index ? iconSelected : icon)
        .width(20)
        .height(20)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#817977')
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(14)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.background_color'))
    .height('100%')
    .width('100%')
  }
}