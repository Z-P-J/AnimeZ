import { getTheme } from '../utils/Themes';
import router from '@ohos.router'

@Component
export default struct TitleBar {
  @StorageLink('theme') theme: number = 0
  private title: string

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .objectFit(ImageFit.Contain)
          .fillColor(getTheme(this.theme).color_text_major)
          .onClick(() => {
            router.back()
          })
        Text(this.title)
          .fontColor(getTheme(this.theme).color_text_major)
          .fontSize(20)
          .fontWeight(500)
          .layoutWeight(1)
          .margin({ left: 16 })
          .align(Alignment.Start)
        Blank()
      }
      .height(56)
      .width('100%')
    }
  }
}