import { PlayerManager } from '../player/PlayerManager';
import { VideoPlayer } from '../player/VideoPlayer';
import { VideoList } from '../components/VideoList';
import EpisodeInfo from '../entity/EpisodeInfo';
import EpisodeList from '../entity/EpisodeList';
import VideoDetailInfo from '../entity/VideoDetailInfo';
import Logger from '../utils/Logger';
import HttpUtils from '../utils/HttpUtils';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import BimiDataSource from '../api/impl/BimiAcgDataSource';
import DataSource from '../api/DataSource';

@Entry
@Component
struct VideoDetailPage {
  @State message: string = 'Hello World'
  @State isLoading: boolean = false
  @State videoDetailInfo: VideoDetailInfo = null
  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiDataSource()

  @State episodeListIndex: number = 0;
  @State episodeIndex: number = 0;

  private playerManager: PlayerManager = new PlayerManager()

  aboutToAppear() {
    this.isLoading = true
    let url = router.getParams()['url']
//    let url = 'http://www.bimiacg4.net/bangumi/bi/8552/'
    promptAction.showToast({ message: 'url=' + url })
    this.getDetailInfo(url)
  }

  build() {

    Stack() {
      if (this.isLoading) {
        // 加载中
        LoadingProgress().width(64).height(64).layoutWeight(1)
      } else {
        Column() {
          VideoPlayer({playerManager: this.playerManager})

          if (this.videoDetailInfo) {
            Scroll() {
              Column({ space: 16 }) {
                Row() {
                  Image(this.videoDetailInfo.coverUrl)
                    .objectFit(ImageFit.Contain)
                    .margin({ right: 16 })
                    .borderRadius(12)
                    .borderWidth(1)
                    .borderColor('#cccccc')
                    .width('33%')
                  Column({ space: 8 }) {
                    Row() {
                      Text(this.videoDetailInfo.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .layoutWeight(1)
                        .align(Alignment.Start)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text("收藏")
                        .fontSize(12)
                        .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                        .borderRadius(8)
                        .margin({ left: 8 })
                        .backgroundColor(Color.Blue)
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                    }

                    if (this.videoDetailInfo.updateTime) {
                      Text(this.videoDetailInfo.updateTime).fontSize(12)
                    }
                    if (this.videoDetailInfo.director) {
                      Text(this.videoDetailInfo.director).fontSize(12)
                    }
                    if (this.videoDetailInfo.category) {
                      Text(`分类：${this.videoDetailInfo.category}`).fontSize(12)
                    }
                    if (this.videoDetailInfo.protagonist) {
                      Text(this.videoDetailInfo.protagonist).fontSize(12)
                    }

                    if (this.videoDetailInfo.desc) {
                      Text(this.videoDetailInfo.desc).fontSize(12)
                        .maxLines(3).textOverflow({overflow:TextOverflow.Ellipsis})
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .padding(16)
                .width('100%')
                .alignItems(VerticalAlign.Top)

                ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
                  Column() {
                    Text(episodeList.title).fontSize(16).fontWeight(FontWeight.Bold).margin({bottom: 12})
                    Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
                      ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
                        Text(item.title)
                          .textAlign(TextAlign.Center)
                          .backgroundColor(
                              (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                              ? Color.Blue : '#aabbcc')
                          .fontColor(Color.White)
                          .fontSize(12)
                          .padding({ top: 8, bottom: 8 })
                          .borderRadius(6)
                          .margin('1%')
                          .width('18%')
                          .onClick(() => {
                            this.playVideo(episodeListIndex, episodeIndex)
                          })

                      })
                    }
                  }
                  .padding({ left: 16, right: 16 })
                  .alignItems(HorizontalAlign.Start)
                })

                Column() {
                  Text("猜你喜欢").fontSize(16).fontWeight(FontWeight.Bold).margin({bottom: 12})
                  VideoList({ videoList: this.videoDetailInfo.recommends, scrollable: false })
                }
                .padding({ left: 16, right: 16 })
                .alignItems(HorizontalAlign.Start)

                Text("没有更多了").fontSize(14)
                  .textAlign(TextAlign.Center)
                  .margin({top: 16, bottom: 32})
                  .width('100%')

              }
              .alignItems(HorizontalAlign.Start)
              .constraintSize({
                minHeight: '100%'
              })
            }
            .edgeEffect(EdgeEffect.Spring)
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  private getDetailInfo(url: string) {
    this.dataSource.getVideoDetailInfo(url)
      .then(async (info) => {
        this.isLoading = false;
        Logger.e(this, 'videoDetailInfo=' + JSON.stringify(info))
        this.videoDetailInfo = info
        this.message = JSON.stringify(info)

        this.playVideo(this.episodeListIndex, this.episodeIndex)
      })
      .catch((e) => {
        this.isLoading = false
        promptAction.showToast({ message: '出错了：' + JSON.stringify(e) })
      })
  }

  private playVideo(episodeListIndex, episodeIndex) {
    this.episodeListIndex = episodeListIndex
    this.episodeIndex = episodeIndex
    let episode = this.videoDetailInfo.episodes[this.episodeListIndex].episodes[this.episodeIndex];
    this.dataSource.parseVideoUrl(episode.link)
      .then((url) => {
        episode.videoUrl = url
        this.playerManager.playEpisode(episode)
      })
  }

}