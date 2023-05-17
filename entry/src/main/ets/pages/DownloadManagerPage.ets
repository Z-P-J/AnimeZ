import { getTheme } from '../utils/Themes';
import TransitionHelper from '../utils/TransitionHelper';
import { ViewState } from '../components/StateView';
import StateView from '../components/StateView';
import TitleBar from '../components/TitleBar';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
@Entry
@Component
struct DownloadManagerPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.EMPTY
  @State errorMessage: string = ''

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
    Column() {
      ImmersionBarSpace()
      TitleBar({ title: '我的收藏' })
      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.Content()
          },
          custom: null,
          onRetry: () => {
            this.loadDownloadItems()
            return true;
          }
        }
      )
        .width('100%')
        .layoutWeight(1)
      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }

  @Builder Content() {
    Column() {

    }
  }

  private loadDownloadItems() {

  }

}