import { getTheme } from '../../utils/Themes';
import DataStore from '../../utils/DataStore';

const KEY = 'key_max_downloading_count'

@CustomDialog
export struct SliderDialog {
  @StorageLink('theme') theme: number = 0
  @State value: number = 1
  private controller: CustomDialogController

  select: (value: number) => void
  onClose: () => void;

  aboutToAppear() {
    this.value = DataStore.get(KEY, 3)
  }

  build() {
    Column() {
      Text('最大下载数')
        .fontSize(18)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16, top: 16 })
        .alignSelf(ItemAlign.Start)
      Row() {
        Slider({
          value: this.value,
          min: 1,
          max: 5,
          step: 1,
          style: SliderStyle.OutSet
        })
          .showSteps(true)
          .layoutWeight(1)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.value = value
          })
        Text(this.value.toFixed(0))
          .fontSize(14)
          .fontColor(getTheme(this.theme).color_text_minor)
          .margin({right: 6})
      }
      .margin(16)

      Row() {
        Text("取消")
          .height("100%")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor(getTheme(this.theme).color_text_normal)
          .onClick(() => {
//            this.controller.close(); // 关闭弹窗
            this.onClose()
          })
        Blank()
          .size({ width: 1.5, height: "30%" })
          .backgroundColor("#80cccccc")
        Text("确定")
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor("#317ef5")
          .height("100%")
          .layoutWeight(1)
          .onClick(() => {
            DataStore.set(KEY, this.value)
            if (this.select) {
              this.select(this.value)
            }
            this.onClose()
//            this.controller.close(); // 关闭弹窗
          })
      }
      .height(46)
      .width('100%')
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .borderRadius(12)
    .width('80%')
  }
}