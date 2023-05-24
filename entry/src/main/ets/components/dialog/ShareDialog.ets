import VideoDetailInfo from '../../entity/VideoDetailInfo';
import { getTheme } from '../../utils/Themes';
import DataStore from '../../utils/DataStore';

@CustomDialog
export struct ShareDialog {
  @StorageLink('theme') theme: number = 0
  private controller: CustomDialogController

  private detailInfo: VideoDetailInfo

  private readonly shareItems = [
    { name: 'QQ', icon: $r('app.media.ic_share_qq'),
      onClick: () => {

      }
    },
    { name: 'QQ空间', icon: $r('app.media.ic_share_qqzone'),
      onClick: () => {
      }
    },
    { name: '新浪', icon: $r('app.media.ic_share_sina'),
      onClick: () => {
      }
    },
    { name: '微信', icon: $r('app.media.ic_share_wechat'),
      onClick: () => {
      }
    },
    { name: '朋友圈', icon: $r('app.media.ic_share_friends'),
      onClick: () => {
      }
    },
    { name: '链接分享', icon: $r('app.media.ic_share_link'),
      onClick: () => {
      }
    }, null, null
  ]

  build() {

    Column({space: 16}) {

      Text('分享')
        .fontSize(18)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
//      Row() {
//        Text('分享')
//          .fontSize(18)
//          .fontColor(getTheme(this.theme).color_text_major)
//          .fontWeight(FontWeight.Medium)
//          .alignSelf(ItemAlign.Start)
//
//        Image($r('app.media.ic_close'))
//          .width(24).height(24)
//      }

      if (this.detailInfo) {
        Column() {
          Text(this.detailInfo.title)
            .fontSize(12)
            .fontWeight(600)
            .fontColor(getTheme(this.theme).color_text_major)
            .alignSelf(ItemAlign.Start)
          Text(this.detailInfo.url)
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
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .padding(24)
    .borderRadius({
      topLeft: 24, topRight: 24
    })
    .width('100%')

//    Stack() {
//
//    }
//    .backgroundColor(getTheme(this.theme).background_color)
//    .borderRadius({
//      topLeft: 24, topRight: 24
//    })
//    .width('100%')
  }
}