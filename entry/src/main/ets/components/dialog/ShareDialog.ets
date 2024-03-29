import ImmersionBarSpace from '../ImmersionBarSpace';
import VideoDetailInfo from '../../entity/VideoDetailInfo';
import { getTheme } from '../../utils/Themes';
import DataStore from '../../utils/DataStore';
import promptAction from '@ohos.promptAction';

/**
 * 自定义分享弹窗
 */
@CustomDialog
export struct ShareDialog {
  @StorageLink('theme') theme: number = 0
  private controller: CustomDialogController

  /**
   * 视频详情信息
   */
  private detailInfo: VideoDetailInfo
  /**
   * 关闭弹窗回调
   */
  private onClose: () => void

  /**
   * 分享选项
   */
  private readonly shareItems = [
    { name: 'QQ', icon: $r('app.media.ic_share_qq'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享到QQ'})
      }
    },
    { name: 'QQ空间', icon: $r('app.media.ic_share_qqzone'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享到QQ空间'})
      }
    },
    { name: '新浪', icon: $r('app.media.ic_share_sina'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享到新浪微博'})
      }
    },
    { name: '微信', icon: $r('app.media.ic_share_wechat'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享到微信'})
      }
    },
    { name: '朋友圈', icon: $r('app.media.ic_share_friends'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享到朋友圈'})
      }
    },
    { name: '链接分享', icon: $r('app.media.ic_share_link'),
      onClick: () => {
        promptAction.showToast({message: 'TODO 分享链接'})
      }
    }, null, null
  ]

  build() {
    Column({space: 16}) {
      Row() {
        Text('分享')
          .fontSize(18)
          .fontColor(getTheme(this.theme).color_text_major)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
        Blank()
        Image($r('app.media.ic_close'))
          .width(24).height(24)
          .onClick(this.onClose)
      }
      .width('100%')

      if (this.detailInfo) {
        Column() {
          Text(this.detailInfo.title)
            .fontSize(14)
            .fontWeight(600)
            .fontColor(getTheme(this.theme).color_text_major)
            .alignSelf(ItemAlign.Start)
          Text(this.detailInfo.url)
            .fontSize(12)
            .fontColor(getTheme(this.theme).primary_color)
            .alignSelf(ItemAlign.Start)
            .margin({top: 6})
        }
        .padding(16)
        .borderRadius(16)
        .width('100%')
        .backgroundColor(getTheme(this.theme).background_color_accent)
      }

      Flex({
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.SpaceAround,
        wrap: FlexWrap.Wrap,
        alignContent: FlexAlign.SpaceBetween
      }) {
        ForEach(this.shareItems, (item) => {
          if (item) {
            Stack() {
              Image(item.icon)
                .width(36)
                .height(36)
            }
            .backgroundColor(getTheme(this.theme).background_color_accent)
            .padding(16)
            .borderRadius(16)
            .margin({ top: 8, bottom: 8 })
            .onClick(item.onClick)
          } else {
            Stack()
              .width(68)
              .height(68)
              .margin({ top: 8, bottom: 8 })
          }
        })
      }

      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .padding(24)
    .borderRadius({
      topLeft: 24, topRight: 24
    })
    .width('100%')
  }
}