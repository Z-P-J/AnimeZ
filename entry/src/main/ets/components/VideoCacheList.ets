import M3U8Downloader from '../player/m3u8/M3U8Downloader';
import { ZDownloader } from '../download/ZDownloader';
import promptAction from '@ohos.promptAction';
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
                      this.downloadAll(episodeList)
                    })
                }
                .padding({ left: 16, top: 16, right: 16, bottom: 8 })
                .width('100%')

                Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
                  ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
                    VideoCacheItem({ episodeInfo: item })
                      .width('22%')
                      .margin({ bottom: 8, right: (episodeIndex + 1) % 4 == 0 ? 0 : '4%' })
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
        Text("下载列表")
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .backgroundColor($r('app.color.primary_color_accent'))
          .fontColor(Color.White)
          .borderRadius(21)
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DownloadManagerPage' })
          })
          .height(42)
          .width('100%')
      }
      .padding({ left: 24, right: 24, top: 12, bottom: 12 })

      ImmersionBarSpace()
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * TODO test缓存全部
   */
  private downloadAll(episodeList: EpisodeList) {
    let observer = {
      onMissionLoaded: (tasks: FileDownloadTask[]) => {
        ZDownloader.get(M3U8Downloader).removeObserver(observer)

        for (let episode of episodeList.episodes) {
          let task = tasks.find((task) => {
            return task.getOriginalUrl() == episode.link
          })
          Logger.e(this, 'find task=' + task + ' link=' + episode.link)
          if (task) {
            continue
          }
          task = ZDownloader.get(M3U8Downloader)
            .with(episode.link)
            .setTaskName(episode.desc)
            .setFileName('index.m3u8')
            .setDownloadDir(getContext(this).filesDir + "/download/")
            .build()
          task.start()
        }

      },
      onMissionCreateFailed: (task: FileDownloadTask, error: any) => {
      },
      onMissionAdd: (task: FileDownloadTask) => {
      },
      onMissionDelete: (task: FileDownloadTask) => {
      },
      onMissionFinished: (task: FileDownloadTask) => {
      }
    }
    ZDownloader.get(M3U8Downloader).addObserver(observer)
  }

}