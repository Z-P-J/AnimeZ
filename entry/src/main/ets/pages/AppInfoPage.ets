import { getTheme } from '../utils/Themes';
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { SettingGroup, SettingsContainer } from '../components/Settings'
import TitleBar from '../components/TitleBar'
import ImmersionBarSpace from '../components/ImmersionBarSpace'
import TransitionHelper from '../utils/TransitionHelper'

@Entry
@Component
struct AppInfoPage {

  @StorageLink('theme') theme: number = 0

  private settings: SettingGroup[] = [
    {
      settings: [
        { title: '应用版本', info: '1.0.0', icon: $r('app.media.ic_version') },
        { title: '应用开发者', info: 'Z-P-J', icon: $r('app.media.ic_author'),
          onClick: () => {
            router.pushUrl({url: 'pages/AboutMePage'})
          }
        },
        { title: '开源仓库', info: 'https://github.com/Z-P-J/AnimeZ', icon: $r('app.media.ic_gitee'),
          onClick: () => {
            router.pushUrl({url: 'pages/WebPage', params: {url: 'https://github.com/Z-P-J/AnimeZ'}})
          }
        },
        { title: '开源社区', info: 'https://gitee.com/ohos-dev', icon: $r('app.media.ic_community'),
          onClick: () => {
            router.pushUrl({url: 'pages/WebPage', params: {url: 'https://gitee.com/ohos-dev'}})
          }
        },
        { title: '开源社区交流群', info: '752399947', icon: $r('app.media.ic_qq'),
          onClick: () => {
            promptAction.showToast({message: 'TODO 跳转开源社区交流群'})
          }
        }
      ]
    }
  ]

  aboutToAppear() {
    getTheme(this.theme).initBar()
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
      TitleBar({title: '应用信息'})

      Scroll() {
        Column() {
          Image($r("app.media.icon"))
            .height(64)
            .width(64)
            .margin({top: 56})
          Text($r('app.string.EntryAbility_label'))
            .fontSize(18)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontWeight(500)
            .padding({ top: 12 })
          Text($r('app.string.module_desc'))
            .fontSize(14)
            .fontColor(getTheme(this.theme).color_text_minor)
            .margin({ top: 8, bottom: 56 })
          ForEach(this.settings, (group, index) => {
            SettingsContainer({ group: group })
            if (index < this.settings.length - 1) {
              Blank().height(16)
            }
          })
        }
        .padding(16)
        .width('100%')
        .constraintSize({
          minHeight: '100%'
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)

      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }

}