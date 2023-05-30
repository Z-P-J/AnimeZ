import { VideoCacheItem } from './VideoCacheItem';
import ImmersionBarSpace from './ImmersionBarSpace';
import router from '@ohos.router';
import EpisodeInfo from '../entity/EpisodeInfo';
import { getTheme } from '../utils/Themes';
import EpisodeList from '../entity/EpisodeList';
import VideoDetailInfo from '../entity/VideoDetailInfo';
import { TaskStatus } from '../download/core/TaskManager';
import { TaskStatusObserver } from '../download/core/TaskManager';
import Logger from '../utils/Logger';
import TaskObserver from '../download/core/TaskObserver';
import { FileDownloadTask } from '../download/FileDownloadTask';

@Component
export struct VideoCacheList {
  @StorageLink('theme') theme: number = 0
  private videoDetailInfo: VideoDetailInfo

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear')

  }

  aboutToDisappear() {
    Logger.e(this, 'aboutToDisappear')

  }

  build() {
    Column() {
      Row() {
        Scroll() {
          Column() {
            ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
              Column() {
                // TODO 展开和折叠、单个下载列表缓存全部
                //                this.Header(episodeList.title)
                Row() {
                  Row()
                    .height(14)
                    .width(6)
                    .margin({ right: 2 })
                    .borderRadius(4)
                    .backgroundColor(getTheme(this.theme).primary_color)
                  Text(episodeList.title)
                    .fontColor(getTheme(this.theme).color_text_major)
                    .fontSize(16)
                  Blank()
                  Text('缓存全部')
                    .fontSize(12)
                    .padding(8)
                    .borderRadius(6)
                    .onClick(() => {
                      // TODO
                    })
                }
                .padding({ left: 16, top: 16, right: 16, bottom: 8 })
                .width('100%')

                Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
                  ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {

                    VideoCacheItem({episodeInfo: item})
                      .width('22%')
                      .margin({ bottom: 8, right: (episodeIndex + 1) % 4 == 0 ? 0 : '4%' })

//                    Text(item.title)
//                      .textAlign(TextAlign.Center)
//                      .backgroundColor(getTheme(this.theme).background_color_accent)
//                      .fontColor(getTheme(this.theme).color_text_major)
//                      .fontSize(12)
//                      .padding({ top: 12, bottom: 12 })
//                      .borderRadius(6)
//                      .margin({ bottom: 8, right: (episodeIndex + 1) % 4 == 0 ? 0 : '4%' })
//                      .width('22%')
//                      .maxLines(1)
                  })
                }
                .margin({ top: 8 })
                .padding({ left: 16, right: 16 })
              }
              .alignItems(HorizontalAlign.Start)
            })
          }
          .alignItems(HorizontalAlign.Start)
          .constraintSize({
            minHeight: '100%'
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        Text("缓存全部")
          .height('100%')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor(getTheme(this.theme).color_text_normal)
          .onClick(() => {
          })
        Stack()
          .size({ width: 1.5, height: '30%' })
          .backgroundColor("#80cccccc")
        Text("下载列表")
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor("#317ef5")
          .height('100%')
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DownloadManagerPage' })
          })
          .height(46)
          .width('100%')
      }
      .height(46)
      .width('100%')

      ImmersionBarSpace()
    }
    .width('100%')
    .layoutWeight(1)
  }

}