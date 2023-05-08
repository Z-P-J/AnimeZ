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
              .borderWidth(1)
              .borderColor('#cccccc')
              .backgroundColor(Color.White)
              .height('180vp')
              .onClick(() => {
                promptAction.showToast({ message: item.url })
                router.pushUrl({ url: 'pages/VideoDetailPage', params: {
                  url: item.url,
                  title: item.title,
                  cover: item.imgUrl
                } })
              })
            }
          })
        }
        .hitTestBehavior(this.scrollable ? HitTestMode.Default : HitTestMode.None)
        .columnsTemplate("1fr 1fr 1fr")
        .columnsGap(16)
        .rowsGap(16)
        .width('100%')
        .height('100%')
      } else {
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween, wrap: FlexWrap.Wrap }) {
          ForEach(this.videoList, (item: VideoInfo) => {
            Column() {
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
              .borderWidth(1)
              .borderColor('#cccccc')
              .backgroundColor(Color.White)
              .width('100%')
              .height('180vp')
              .onClick(() => {
                promptAction.showToast({ message: item.url })
                router.pushUrl({ url: 'pages/VideoDetailPage', params: {
                  url: item.url,
                  title: item.title,
                  cover: item.imgUrl
                } })
              })
            }
            .padding({ bottom: 16, right: 16 })
            .width('33.3%')
          })
        }
      }
    }

  }
}