import { getTheme } from '../utils/Themes';
import { RadioDialog } from '../components/dialog/RadioDialog';
import DataStore from '../utils/DataStore';
import { SliderDialog } from '../components/dialog/SliderDialog';
//import { CustomBatteryDialog } from '../components/dialog/CustomBatteryDialog';
import TitleBar from '../components/TitleBar'
import { SettingGroup, SettingsList } from '../components/Settings'
import ImmersionBarSpace from '../components/ImmersionBarSpace'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import TransitionHelper from '../utils/TransitionHelper'

@Entry
@Component
struct SettingsPage {

  @StorageLink('theme') theme: number = 0

  private settings: SettingGroup[] = [
    {
      title: '界面',
      settings: [
        { title: '首页数据源',
          preference: {
            key: 'key_homepage_source',
            type: 'radio',
            defaultValue: 0,
            values: ['数据源一', '数据源二', '数据源三'],
            onValueChange: (key, value) => {
              promptAction.showToast({ message: 'TODO key=' + key + ' value=' + value })
            }
          }
        },
        { title: '主题', info: '纯白',
          preference: {
            key: 'key_theme_id',
            type: 'radio',
            defaultValue: 0,
            values: ['白天', '夜晚'],
            onValueChange: (key, value) => {
              promptAction.showToast({ message: 'TODO key=' + key + ' value=' + value })
            }
          }
        }
      ]
    },
    {
      title: '播放',
      settings: [
        {
          title: '自动播放下一集',
          info: '视频结束后自动播放下一集',
          preference: {
            key: 'key_auto_play_next_episode',
            type: 'switch',
            defaultValue: true,
            onValueChange: (key, value) => {
              promptAction.showToast({ message: 'TODO key=' + key + ' value=' + value })
            }
          }
        },
        {
          title: '非Wifi下自动播放',
          info: '非Wifi环境下不再提醒，自动播放视频',
          preference: {
            key: 'key_auto_play_on_no_wifi',
            type: 'switch',
            defaultValue: true,
            onValueChange: (key, value) => {
              promptAction.showToast({ message: 'TODO key=' + key + ' value=' + value })
            }
          }
        }
      ]
    },
    {
      title: '下载',
      settings: [
        {
          title: '自动恢复下载',
          info: 'Wifi环境下软件启动后自动恢复未完成的下载任务',
          preference: {
            key: 'key_auto_resume_download_on_wifi',
            type: 'switch',
            defaultValue: true,
            onValueChange: (key, value) => {
              promptAction.showToast({ message: 'TODO key=' + key + ' value=' + value })
            }
          }
        },
        { title: '最大同时下载任务数', info: '' + DataStore.get('key_max_downloading_count', 3),
          onClick: (item, callback) => {
            let controller = new CustomDialogController({
              builder: SliderDialog({
                select: (value) => {
                  if (callback) {
                    item.info = '' + value
                    callback()
                  }
                },
                onClose: () => {
                  controller.close()
                }
              }),
              cancel: () => {
                console.log("cancel")
              },
              autoCancel: true,
              customStyle: true
            });
            controller.open()
          }
        }
      ]
    },
    {
      title: '更多',
      settings: [
        {
          title: '检查更新',
          info: '1.0.0',
          //          icon: $r('app.media.ic_upgrade'),
          iconBlendColor: Color.Black,
          onClick: () => {
            promptAction.showToast({ message: 'TODO 检查更新' })
          }
        },
        {
          title: '应用信息',
          info: $r('app.string.module_desc'),
          //          icon: $r('app.media.ic_application'),
          onClick: () => {
            router.pushUrl({ url: 'pages/AppInfoPage' })
          }
        },
        {
          title: '关于作者',
          info: '这人很懒，什么都没有写！',
          //          icon: $r('app.media.ic_author'),
          onClick: () => {
            router.pushUrl({ url: 'pages/AboutMePage' })
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
      TitleBar({ title: '设置' })
      SettingsList({ settings: this.settings })
        .layoutWeight(1)

      Text('本应用仅供学习交流！')
        .fontSize(10)
        .padding(8)

      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }
}