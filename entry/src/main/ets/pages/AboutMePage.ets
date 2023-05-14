import promptAction from '@ohos.promptAction'
import { SettingGroup, SettingsContainer } from '../components/Settings'
import TitleBar from '../components/TitleBar'
import ImmersionBarSpace from '../components/ImmersionBarSpace'
import TransitionHelper from '../utils/TransitionHelper'

@Entry
@Component
struct AboutMePage {

  private settings: SettingGroup[] = [
    {
      settings: [
        { title: 'Github主页', info: 'https://github.com/Z-P-J', icon: $r('app.media.ic_github'),
          onClick: () => {
            promptAction.showToast({message: 'TODO 打开Github主页'})
          }
        },
        { title: 'Gitee主页', info: 'https://gitee.com/z-p-j', icon: $r('app.media.ic_gitee'),
          onClick: () => {
            promptAction.showToast({message: 'TODO 打开Gitee主页'})
          }
        },
        { title: '赞助作者', info: '赞助一杯咖啡，让作者继续熬夜写代码', icon: $r('app.media.ic_java'),
          onClick: () => {
            promptAction.showToast({message: '该功能暂未实现，感谢您的赞助！'})
          }
        }
      ]
    }
  ]

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
            .borderWidth(1)
            .borderColor('#cccccc')
          Text('Z-P-J')
            .fontSize(18)
            .fontColor($r('app.color.color_text_major'))
            .fontWeight(500)
            .padding({ top: 12 })
          Text('开源鸿蒙应用开发爱好者，为开源鸿蒙应用生态作出微薄的贡献')
            .fontSize(14)
            .fontColor($r('app.color.color_text_minor'))
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
    .backgroundColor($r('app.color.background_color_accent'))
    .width('100%')
    .height('100%')
  }
}