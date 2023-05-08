import { PlayerStatus } from './PlayerStatus';
import {PlayerController} from './PlayerController';
import { PlayerManager } from './PlayerManager';
import Logger from '../utils/Logger';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import VideoInfo from '../entity/VideoInfo';


@Component
export struct VideoPlayer {
  @State aspRatio: number = 1.7;
  @State playStatus: number = PlayerStatus.INIT;
  @State videoUrl: string = ''
  @State playerStatus: PlayerStatus = PlayerStatus.INIT

  private playerManager: PlayerManager = null;


  aboutToAppear() {
    if (this.playerManager) {
      this.playerManager.addListener((status) => {
        this.playerStatus = status;
      })
      this.playerManager.setVideoSizeChangedListener((w, h) => {
        this.aspRatio = w / h;
        promptAction.showToast({message: 'aspRatio=' + this.aspRatio})
      })
    } else {
      throw new Error('You must set playerManager firstly!')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      XComponent({
        id: 'xcomponentId',
        type: 'surface',
        libraryname: 'ijkplayer_napi'
      })
        .onLoad((context) => {
          this.playerManager.init(context)
        })
        .onDestroy(() => {
        })
        .width('100%')
        .height('100%')
        .aspectRatio(this.aspRatio)

      PlayerController({playerManager: this.playerManager})
        .width('100%')
        .height('100%')
    }
    .backgroundColor(Color.Black)
    .width('100%')
    .height('100%')
    .aspectRatio(this.aspRatio)
  }
}