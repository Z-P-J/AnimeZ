import router from '@ohos.router';
import { getTheme } from '../utils/Themes';
import promptAction from '@ohos.promptAction'
import { SettingGroup, SettingsContainer } from '../components/Settings'
import TitleBar from '../components/TitleBar'
import ImmersionBarSpace from '../components/ImmersionBarSpace'
import TransitionHelper from '../utils/TransitionHelper'

@Entry
@Component
struct AboutMePage {

  @StorageLink('theme') theme: number = 0

  private settings: SettingGroup[] = [
    {
      settings: [
        { title: 'Github主页', info: 'https://github.com/Z-P-J', icon: $r('app.media.ic_github'),
          onClick: () => {
            router.pushUrl({url: 'pages/WebPage', params: {url: 'https://github.com/Z-P-J'}})
          }
        },
        { title: 'Gitee主页', info: 'https://gitee.com/z-p-j', icon: $r('app.media.ic_gitee'),
          onClick: () => {
            router.pushUrl({url: 'pages/WebPage', params: {url: 'https://gitee.com/z-p-j'}})
          }
        },
        { title: '赞助作者', info: '赞助作者一杯咖啡', icon: $r('app.media.ic_java'),
          onClick: () => {
            promptAction.showToast({message: '该功能暂未实现，感谢您的支持！'})
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
      TitleBar({title: '关于作者'})

      Scroll() {
        Column() {
          Image($r("app.media.ic_author"))
            .height(64)
            .width(64)
            .margin({top: 56})
            .borderRadius(32)
            .shadow({ radius: 12, color: getTheme(this.theme).isDarkTheme ? '#333333' : '#aaaaaa', offsetX: 6, offsetY: 6 })
          Text('Z-P-J')
            .fontSize(18)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontWeight(500)
            .padding({ top: 12 })
          Text('开源鸿蒙应用开发爱好者，为开源鸿蒙应用生态作出微薄的贡献')
            .fontSize(14)
            .fontColor(getTheme(this.theme).color_text_minor)
            .margin({ top: 8, bottom: 56 })
            .textAlign(TextAlign.Center)
            .constraintSize({
              maxWidth: '80%'
            })
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