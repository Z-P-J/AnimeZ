import { getTheme } from '../utils/Themes';
import router from '@ohos.router'
import promptAction from '@ohos.promptAction';

@Component
export default struct CustomPanel {
  @StorageLink('theme') theme: number = 0
  @Watch("onShowPanelChanged") @Link showPanel: boolean
  @State showPanelInner: boolean = false
  @State ty: number = 0
  @State panelOpacity: number = 0
  @State panelHeight: number = 0;
  @BuilderParam content: () => any;

  build() {
    Stack() {
      if (this.showPanelInner) {
//        Stack() {
//          Column() {
//            this.content()
//          }
//          .animation({
//            duration: 500,
//            curve: Curve.Friction,
//            iterations: 1,
//            playMode: PlayMode.Normal
//          })
//          .backgroundColor($r('app.color.background_color_accent'))
//          .translate({ y: this.ty })
//          .width('100%')
//          .height('100%')
//          .onAppear(() => {
////            this.ty = 0
//            promptAction.showToast({message: 'show'})
//          })
//        }
//        .backgroundColor('#80000000')
//        .opacity(this.panelOpacity)
//        .animation({
//          duration: 500,
//          curve: Curve.Friction,
//          iterations: 1,
//          playMode: PlayMode.Normal,
//          onFinish: () => {
//            if (this.panelOpacity === 0) {
//              this.showPanelInner = false
//            }
//          }
//        })
//        .width('100%')
//        .height('100%')
//        .onAppear(() => {
//          this.panelOpacity = 1
////          this.ty = 0
//        })
//        .onClick(() => {
////          this.ty = -this.panelHeight
////          this.panelOpacity = 0
//          this.showPanel = false
//        })



        Column() {
          this.content()
        }
        .animation({
          duration: 500,
          curve: Curve.Friction,
          iterations: 1,
          playMode: PlayMode.Normal,
          onFinish: () => {
            if (this.panelOpacity === 0) {
              this.showPanelInner = false
            }
          }
        })
        .backgroundColor(getTheme(this.theme).background_color_accent)
        .translate({ y: this.ty })
        .width('100%')
        .height('100%')
        .opacity(this.panelOpacity)
        .onAppear(() => {
          this.panelOpacity = 1
          this.ty = 0
          promptAction.showToast({message: 'show'})
        })
        .onClick(() => {
          //          this.ty = -this.panelHeight
          //          this.panelOpacity = 0
          this.showPanel = false
        })

      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_, newArea) => {
      this.panelHeight = parseInt(newArea.height.toString())
      this.ty = -this.panelHeight
    })
  }

  onShowPanelChanged() {
    if (this.showPanel) {
      if (!this.showPanelInner) {
        this.showPanelInner = true
      }
    } else {
      if (this.showPanelInner) {
        this.ty = -this.panelHeight
        this.panelOpacity = 0
      }
    }
  }

}