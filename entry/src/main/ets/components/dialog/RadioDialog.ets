import DataStore from '../../utils/DataStore';

@CustomDialog
export struct RadioDialog {
  @State checkIndex: number = 1
  private controller: CustomDialogController
  private title: string
  private prefKey: string
  private values: string[]
  private onSelect: (index) => void

  aboutToAppear() {
    this.checkIndex = DataStore.get(this.prefKey, 0)
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
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
              .fontColor($r('app.color.color_text_major'))
          }
          .width('100%')
          .onClick(() => {
            this.checkIndex = i
          })
        })

        //        Radio({ value: 'Radio1', group: 'radioGroup' }).checked(true)
        //          .height(50)
        //          .width(50)
        //          .onChange((isChecked: boolean) => {
        //            console.log('Radio1 status is ' + isChecked)
        //          })

      }
      .margin(16)

//      Row() {
//        Slider({
//          value: this.value,
//          min: 1,
//          max: 5,
//          step: 1,
//          style: SliderStyle.OutSet
//        })
//          .showSteps(true)
//          .layoutWeight(1)
//          .onChange((value: number, mode: SliderChangeMode) => {
//            this.value = value
//          })
//        Text(this.value.toFixed(0))
//          .fontSize(14)
//          .fontColor($r('app.color.color_text_minor'))
//          .margin({ right: 6 })
//      }
//      .margin(16)

      Row() {
        Text("取消")
          .height("100%")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor($r('app.color.color_text_normal'))
          .onClick(() => {
            this.controller.close(); // 关闭弹窗
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
            DataStore.set(this.prefKey, this.checkIndex)
            if (this.onSelect) {
              this.onSelect(this.checkIndex)
            }
            this.controller.close(); // 关闭弹窗
          })
      }
      .height(46)
      .width('100%')
    }
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(12)
    .width('80%')
  }
}