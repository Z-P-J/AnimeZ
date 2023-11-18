import { getTheme } from '../utils/Themes';
import Logger from '../utils/Logger';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import router from '@ohos.router';
import Webview from '@ohos.web.webview';
import { OPTIONS_TRANSITION_POP, OPTIONS_TRANSITION_PUSH } from '../utils/TransitionHelper';

const USER_AGENT = 'Mozilla/5.0 (Linux; Android 12; HarmonyOS; OCE-AN10; HMSCore 6.8.0.332) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.88 HuaweiBrowser/13.0.0.303 Mobile Safari/537.36'

@Entry
@Component
struct WebPage {
  @StorageLink('theme') theme: number = 0
  @State title: string = ''
  @State info: string = ''
  @State loadingProgress: number = 0
  private readonly controller: Webview.WebviewController = new Webview.WebviewController()
  private url: string | Resource = null


  aboutToAppear() {
    const url: string = router.getParams()['url']
    if (!url) {
      router.back()
      return
    }

    if (url.startsWith('http')) {
      this.url = url
    } else {
      this.url = $rawfile(url)
    }
    this.title = url
    this.info = this.title
    getTheme(this.theme).initBar()
  }

  onBackPress() {
    if (this.controller.accessBackward()) {
      this.controller.backward()
      return true
    }
    return false
  }

  pageTransition() {
    PageTransitionEnter(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Right)
    PageTransitionEnter(OPTIONS_TRANSITION_POP).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_POP).slide(SlideEffect.Right)
  }

  build() {
    Column() {
      ImmersionBarSpace()
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 12, right: 12 })
          .fillColor(getTheme(this.theme).color_text_major)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })
        Column() {
          Text(this.title)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontSize(16)
            .maxLines(1)
            .fontWeight(500)
            .textOverflow({overflow: TextOverflow.Ellipsis})
            .textAlign(TextAlign.Start)

          Text(this.info)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontSize(10)
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
            .margin({top: 4})
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Image($r('app.media.ic_refresh'))
          .width(24)
          .height(24)
          .margin({ left: 12, right: 12 })
          .fillColor(getTheme(this.theme).color_text_major)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.controller.refresh()
          })
      }
      .height(56)
      .width('100%')
      if (this.loadingProgress < 100) {
        Progress({ value: this.loadingProgress, total: 100, type: ProgressType.Linear })
          .color(getTheme(this.theme).primary_color)
          .width('100%').height(4)
      }
      Web({ src: this.url, controller: this.controller })
        .userAgent(USER_AGENT)
        .javaScriptAccess(true)
        .darkMode(getTheme(this.theme).isDarkTheme ? WebDarkMode.On : WebDarkMode.Off)
        .backgroundColor(getTheme(this.theme).background_color_accent)
        .forceDarkAccess(true)
        .onTitleReceive((event) => {
          this.title = event.title
        })
        .onProgressChange((event) => {
          this.loadingProgress = event.newProgress
        })
        .onPageBegin(event => {
          Logger.e(this, "onPageBegin url=" + event.url)
          if (!event.url.startsWith('file:')) {
            this.info = event.url
          }
        })
        .onPageEnd(event => {
          let url = event.url
          Logger.e(this, "onPageEnd url=" + url)
        })
        .width('100%')
        .layoutWeight(1)
      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }
}