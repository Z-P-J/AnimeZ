import { PlayerStatus } from '../player/PlayerStatus';
import Logger from '../utils/Logger';

@Entry
@Component
struct Page2 {
  @State message: string = 'Hello World'
  @State playerStatus: number = PlayerStatus.INIT

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear playerStatus=' + this.playerStatus)
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}