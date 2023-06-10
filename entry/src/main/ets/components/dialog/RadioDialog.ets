import { getTheme } from '../../utils/Themes';
import DataStore from '../../utils/DataStore';

@CustomDialog
export struct RadioDialog {
  @StorageLink('theme') theme: number = 0
  @State checkIndex: number = 0
  private controller: CustomDialogController
  private title: string
  private prefKey: string
  private values: string[]
  private onSelect: (index) => void

  aboutToAppear() {
    this.checkIndex = DataStore.getInt(this.prefKey, 0)
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16, top: 16 })
        .alignSelf(ItemAlign.Start)

      Column() {

        ForEach(this.values, (item, i) => {
          Row() {
            Radio({ value: item, group: 'radioGroup' })
              .checked(this.checkIndex === i)
              .height(20)
              .width(20)
              .onChange((isChecked: boolean) => {
                console.log('Radio1 status is ' + isChecked)
                if (isChecked) {
                  this.checkIndex = i
                }
              })
            Text(item).fontSize(14)
              .fontColor(getTheme(this.theme).color_text_major)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.checkIndex = i
          })
        })
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
            this.controller.close();
          })
        Row()
          .size({ width: 1.5, height: 14 })
          .backgroundColor("#80cccccc")
        Text("确定")
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor("#317ef5")
          .height("100%")
          .layoutWeight(1)
          .onClick(() => {
            if (this.onSelect) {
              this.onSelect(this.checkIndex)
            }
            this.controller.close();
          })
      }
      .height(46)
      .width('100%')
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .borderRadius(16)
    .width('80%')
  }
}