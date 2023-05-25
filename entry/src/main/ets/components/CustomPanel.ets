import { getTheme } from '../utils/Themes';
import router from '@ohos.router'
import promptAction from '@ohos.promptAction';

@Component
export default struct CustomPanel {
  @StorageLink('theme') theme: number = 0
  @Watch("onShowPanelChanged") @Link showPanel: boolean
  @Watch('onShowPanelInnerChanged') @State showPanelInner: boolean = false
  @State ty: number = 0
  @State panelOpacity: number = 0
  @State panelHeight: number = 0;
//  @BuilderParam rootContent: () => any;
  @BuilderParam panelContent: () => any;

  build() {
    Stack() {
//      this.rootContent()
      if (this.showPanelInner) {
        Column()
          .backgroundColor('#80000000')
          .width('100%')
          .height('100%')
          .opacity(this.panelOpacity)
          .onClick(() => {
            this.showPanel = false
          })
        Stack() {
          this.panelContent()
        }
        .translate({ y: this.ty })
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.showPanel = false
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_, newArea) => {
      this.panelHeight = parseInt(newArea.height.toString())
      this.ty = this.panelHeight
    })
  }

  onShowPanelInnerChanged() {
    promptAction.showToast({ message: 'onShowPanelInnerChanged showPanelInner=' + this.showPanelInner })
  }

  onShowPanelChanged() {
    promptAction.showToast({
      message: 'onShowPanelChanged ' + this.showPanel + ' showPanelInner=' + this.showPanelInner
    })
    if (this.showPanel) {
      if (!this.showPanelInner) {
        //        this.ty = this.panelHeight
        this.showPanelInner = true

        setTimeout(() => {
          animateTo({
            duration: 360,
            curve: Curve.Smooth,
            iterations: 1,
            playMode: PlayMode.Normal,
            onFinish: () => {
              //            this.showPanelInner = false
            }
          }, () => {
            this.ty = 0
            this.panelOpacity = 1
          })
        }, 10)
      }
    } else {
      if (this.showPanelInner) {
        animateTo({
          duration: 360,
          curve: Curve.ExtremeDeceleration,
          iterations: 1,
          playMode: PlayMode.Normal,
          onFinish: () => {
            this.showPanelInner = false
          }
        }, () => {
          this.ty = this.panelHeight
          this.panelOpacity = 0
        })
      }
    }
  }
}