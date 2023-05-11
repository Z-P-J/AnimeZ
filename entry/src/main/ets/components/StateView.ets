
export enum ViewState {

  LOADING = 0,
  CONTENT,
  EMPTY,
  ERROR,
  CUSTOM

}

@Component
export default struct StateView {

  @Link state: number
  @BuilderParam content: () => any;
//  @BuilderParam loading?: () => any;
//  @BuilderParam empty?: () => any;
  @BuilderParam custom: (key) => any;
  onRetry?: () => boolean;

  build() {
    Stack({alignContent: Alignment.Center}) {
      if (this.state == ViewState.LOADING) {
        // 加载中
        LoadingProgress().width(64).height(64).layoutWeight(1)
      } else if (this.state == ViewState.CONTENT) {
        if (this.content) {
          this.content()
        }
      } else if (this.state == ViewState.EMPTY) {
        Text("空空如也").fontSize(18).padding(20).fontWeight(FontWeight.Bold).layoutWeight(1)
          .onClick(() => {
            if (this.onRetry) {
              this.onRetry()
            }
          })
      } else if (this.state == ViewState.ERROR) {
        Text("出错了，点击重试").fontSize(18).padding(20).fontWeight(FontWeight.Bold).layoutWeight(1)
          .onClick(() => {
            if (this.onRetry) {
              this.onRetry()
            }
          })
      } else if (this.state == ViewState.CUSTOM) {
        if (this.custom) {
          this.custom('key')
        }
      }

    }
    .width('100%')
    .height('100%')
  }

}