import { getCurrentTheme, getTheme } from '../utils/Themes';
import { MyPageTabContent } from '../components/MyPage';
import { HomepageTabContent } from '../components/Homepage';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { OPTIONS_TRANSITION_POP, OPTIONS_TRANSITION_PUSH } from '../utils/TransitionHelper';

@Entry
@Component
struct Index {
  @StorageLink('theme') theme: number = 0
  @State currentIndex: number = 0
  @State onShow: boolean = false
  private controller: TabsController = new TabsController()

  aboutToAppear() {
    this.theme = getCurrentTheme()
    getTheme(this.theme).initBar()
  }

  onPageShow() {
    getTheme(this.theme).initBar()
    this.onShow = true
  }

  onPageHide() {
    this.onShow = false
  }

  pageTransition() {
    PageTransitionEnter(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Right)
    PageTransitionEnter(OPTIONS_TRANSITION_POP).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_POP).slide(SlideEffect.Right)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          HomepageTabContent()
        }
        .tabBar(this.TabBarBuilder(0, '首页', $r('app.media.ic_homepage'), $r('app.media.ic_homepage_selected')))

        TabContent() {
          MyPageTabContent({onShow: $onShow})
        }
        .tabBar(this.TabBarBuilder(1, '我的', $r('app.media.ic_me'), $r('app.media.ic_me_selected')))
      }
      .vertical(false)
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(48)
      .backgroundColor(getTheme(this.theme).background_color_accent)
      //      .animationDuration(420)
      .onChange((index: number) => {
        this.currentIndex = index
      })

      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color)
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
    .backgroundColor(getTheme(this.theme).background_color)
    .height('100%')
    .width('100%')
  }
}