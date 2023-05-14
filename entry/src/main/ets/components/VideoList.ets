import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import VideoInfo from '../entity/VideoInfo';

@Component
export struct VideoList {
  videoList: VideoInfo[] = []
  private scrollable: boolean = true

  build() {
    Column() {
      if (this.scrollable) {
        Grid() {
          ForEach(this.videoList, (item: VideoInfo) => {
            GridItem() {
              this.VideoItem(item)
            }
          })
        }
        .hitTestBehavior(this.scrollable ? HitTestMode.Default : HitTestMode.None)
        .columnsTemplate("1fr 1fr 1fr")
        .columnsGap(4)
        .rowsGap(4)
        .width('100%')
        .height('100%')
      } else {
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween, wrap: FlexWrap.Wrap }) {
          ForEach(this.videoList, (item: VideoInfo) => {
            Column() {
              this.VideoItem(item)
            }
            .padding({ bottom: 4, right: 4 })
            .width('33.3%')
          })
        }
      }
    }
  }

  @Builder VideoItem(item: VideoInfo) {
    Column() {
      if (item.imgUrl) {
        Image(item.imgUrl)
          .alt($r('app.media.pic_load_failed'))
          .borderRadius({ topLeft: 8, topRight: 8 })
          .width('100%')
          .layoutWeight(1)
      } else {
        Image($r('app.media.pic_load_failed'))
          .borderRadius({ topLeft: 8, topRight: 8 })
          .width('100%')
          .layoutWeight(1)
      }
      Text(item.title)
        .height(40)
        .fontSize(12)
        .maxLines(2)
        .padding({ left: 2, right: 2 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .fontWeight(500)
    }
    .borderRadius(8)
    .borderWidth(2)
    .borderColor($r('app.color.background_color_dark'))
    .backgroundColor($r('app.color.background_color'))
    .aspectRatio(0.618)
    .onClick(() => {
      promptAction.showToast({ message: item.url })
      router.pushUrl({ url: 'pages/VideoDetailPage', params: {
        url: item.url,
        title: item.title,
        cover: item.imgUrl
      } })
    })
  }

}