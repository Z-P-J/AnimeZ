
export class PanelController {

  private listener: (show: boolean) => void
  private toShow: boolean = false

  setListener(listener: (show: boolean) => void) {
    this.listener = listener
  }

  isShow() {
    return this.toShow;
  }

  close() {
    this.toShow = false
    if (this.listener) {
      this.listener(false)
    }
  }

  show() {
    this.toShow = true
    if (this.listener) {
      this.listener(true)
    }
  }


}

@Component
export default struct CustomPanel {
  @StorageLink('theme') theme: number = 0
//  @Watch("onShowPanelChanged") @State showPanel: boolean = false
  // TODO 改为panel state
  @State showPanelInner: boolean = false
  @State translateY: number = 0
  @State panelOpacity: number = 0
  @State panelHeight: number = 0
  @BuilderParam panelContent: () => any
  private controller: PanelController
  private onClose: () => void

  aboutToAppear() {
    if (this.controller) {
      this.controller.setListener((show) => {
        this.onShowPanelChanged(show)
      })
    } else {
      throw new Error('You must set controller first!')
    }
  }

  build() {
    Stack() {
      if (this.showPanelInner) {
        Column()
          .backgroundColor('#80000000')
          .width('100%')
          .height('100%')
          .opacity(this.panelOpacity)
          .onClick(() => {
//            this.showPanel = false
            this.controller.close()
          })
        Stack() {
          this.panelContent()
        }
        .translate({ y: this.translateY })
        .width('100%')
        .height('100%')
        .onClick(() => {})
//        .onClick(() => {
////          this.showPanel = false
//        })
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.showPanelInner ? HitTestMode.Default : HitTestMode.None)
    .onAreaChange((_, newArea) => {
      this.panelHeight = parseInt(newArea.height.toString())
      if (this.showPanelInner) {
        this.translateY = 0
      } else {
        this.translateY = this.panelHeight
      }
    })
    .onClick(() => {
      this.controller.close()
    })
  }

  onShowPanelChanged(show: boolean) {
    if (show) {
      if (!this.showPanelInner) {
        //        this.ty = this.panelHeight
        this.showPanelInner = true

        setTimeout(() => {
          animateTo({
            duration: 360,
            curve: Curve.ExtremeDeceleration,
            iterations: 1,
            playMode: PlayMode.Normal
          }, () => {
            this.translateY = 0
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
          this.translateY = this.panelHeight
          this.panelOpacity = 0
        })
      }
    }
  }
}