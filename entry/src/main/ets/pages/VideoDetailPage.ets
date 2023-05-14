import SystemBarUtils from '../utils/SystemBarUtils';
import { PlayerStatus } from '../player/PlayerStatus';
import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import SQLite from '../db/SQLite';
import StateView from '../components/StateView';
import { ViewState } from '../components/StateView';
import TransitionHelper from '../utils/TransitionHelper';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
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
import BimiAcgDataSource from '../api/impl/BimiAcgDataSource';
import DataSource from '../api/DataSource';
import window from '@ohos.window';

@Entry
@Component
struct VideoDetailPage {
  @State videoDetailInfo: VideoDetailInfo = null
  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiAcgDataSource()
  @State episodeListIndex: number = 0;
  @State episodeIndex: number = 0;
  @State state: number = ViewState.LOADING
  @State errorMessage: string = ''
  private playerManager: PlayerManager = new PlayerManager()
  private url: string
  private historyInfo: VideoHistoryInfo

  aboutToAppear() {
    this.url = router.getParams()['url']
    //    this.url = 'http://www.bimiacg4.net/bangumi/bi/8552/'
    promptAction.showToast({ message: 'url=' + this.url })

    SQLite.with(VideoHistoryTable)
      .queryByLink(this.url)
      .then((info) => {
        if (info) {
          this.historyInfo = info
        } else {
          this.historyInfo = VideoHistoryInfo.createByLink(this.url)
        }
        this.getDetailInfo()
      })
      .catch((e) => {
        Logger.e(this, 'query info by link error! e=' + JSON.stringify(e))
        this.historyInfo = VideoHistoryInfo.createByLink(this.url)
        this.getDetailInfo()
      })
  }

  aboutToDisappear() {
    SystemBarUtils.setWindowSystemBarProperties({
      statusBarColor: '#00000000',
      statusBarContentColor: '#000000',
      navigationBarColor: '#00000000',
      navigationBarContentColor: '#000000'
    })
    this.saveHistoryInfo()
  }

  pageTransition() {
    PageTransitionEnter(TransitionHelper.OPTIONS_TRANSITION_PUSH)
      .slide(SlideEffect.Right)

    PageTransitionEnter(TransitionHelper.OPTIONS_TRANSITION_POP)
      .slide(SlideEffect.Left)

    PageTransitionExit(TransitionHelper.OPTIONS_TRANSITION_PUSH)
      .slide(SlideEffect.Left)

    PageTransitionExit(TransitionHelper.OPTIONS_TRANSITION_POP)
      .slide(SlideEffect.Right)
  }

  build() {
    Stack() {
      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.Content()
          },
          custom: null,
          onRetry: () => {
            this.getDetailInfo()
            return true;
          }
        }
      )
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder Content() {
    Column() {
      ImmersionBarSpace().backgroundColor(Color.Black)
      VideoPlayer({ playerManager: this.playerManager })
      if (this.videoDetailInfo) {
        Scroll() {
          Column({ space: 16 }) {
            this.VideoDetail()
            this.EpisodeList()
            this.GuessYouLike()
            Text("没有更多了").fontSize(14)
              .textAlign(TextAlign.Center)
              .margin({ top: 16, bottom: 32 })
              .width('100%')
            ImmersionBarSpace()
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

  @Builder VideoDetail() {
    Row() {
      Image(this.videoDetailInfo.coverUrl)
        .objectFit(ImageFit.Contain)
        .margin({ right: 16 })
        .borderRadius(8)
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
            .padding({ top: 8, bottom: 8, left: 16, right: 16 })
            .borderRadius(4)
            .margin({ left: 8 })
            .backgroundColor($r('app.color.primary_color'))
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
            .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .padding(16)
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder EpisodeList() {
    ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
      Column() {
        Text(episodeList.title).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween, wrap: FlexWrap.Wrap }) {
          ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
            Text(item.title)
              .textAlign(TextAlign.Center)
              .backgroundColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? $r('app.color.primary_color') : '#f5f5f5')
              .fontColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? Color.White : $r('app.color.color_text_major'))
              .fontSize(12)
              .padding({ top: 8, bottom: 8, left: 12, right: 12 })
              .borderRadius(4)
              .margin({ bottom: 8 })
              .width('18%')
              .maxLines(1)
              .onClick(() => {
                this.historyInfo.videoProgress = 0
                this.historyInfo.currentTime = 0
                this.historyInfo.totalTime = 0
                this.playVideo(episodeListIndex, episodeIndex)
              })
          })
        }
      }
      .padding({ left: 16, right: 16 })
      .alignItems(HorizontalAlign.Start)
    })
  }

  @Builder GuessYouLike() {
    Column() {
      Text("猜你喜欢").fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
      VideoList({ videoList: this.videoDetailInfo.recommends, scrollable: false })
    }
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  private getDetailInfo() {
    this.dataSource.getVideoDetailInfo(this.url)
      .then(async (info) => {
        Logger.e(this, 'videoDetailInfo=' + JSON.stringify(info))

        SystemBarUtils.setWindowSystemBarProperties({
          statusBarColor: '#00000000',
          statusBarContentColor: '#ffffff',
          navigationBarColor: '#ddffffff',
          navigationBarContentColor: '#000000'
        })

        this.playerManager.addListener((status) => {
          if (status == PlayerStatus.DONE) {
            let episodeList = this.videoDetailInfo.episodes[this.episodeListIndex]
            if (this.episodeIndex < episodeList.episodes.length - 1) {
              this.playVideo(this.episodeListIndex, this.episodeIndex + 1)
            }
          }
        })

        this.videoDetailInfo = info
        this.state = ViewState.CONTENT

        this.historyInfo.title = this.videoDetailInfo.title
        this.historyInfo.coverUrl = this.videoDetailInfo.coverUrl



        this.playVideo(this.episodeListIndex, this.episodeIndex)
      })
      .catch((e) => {
        this.errorMessage = JSON.stringify(e)
        this.state = ViewState.ERROR
      })
  }

  private playVideo(episodeListIndex, episodeIndex) {
    this.episodeListIndex = episodeListIndex
    this.episodeIndex = episodeIndex
    let episode = this.videoDetailInfo.episodes[this.episodeListIndex].episodes[this.episodeIndex];

    this.historyInfo.episodeListIndex = episodeListIndex
    this.historyInfo.episodeIndex = episodeIndex
    this.historyInfo.episodeName = episode.title
    this.historyInfo.videoUrl = episode.videoUrl
    //    this.historyInfo.videoProgress = 0
    //    this.historyInfo.currentTime = 0
    //    this.historyInfo.totalTime = 0

    if (episode.videoUrl) {
      this.play(episode)
    } else {
      this.dataSource.parseVideoUrl(episode.link)
        .then((url) => {
          episode.videoUrl = url
          this.historyInfo.videoUrl = episode.videoUrl
          this.play(episode)
        })
        .catch((e) => {
          Logger.e(this, 'parseVideoUrl failed! e=' + JSON.stringify(e))
        })
    }
  }

  private play(episode) {
    this.saveHistoryInfo()
    this.playerManager.playEpisode(episode)
  }

  private saveHistoryInfo() {
    if (this.historyInfo) {
      this.historyInfo.accessTime = new Date().getTime()
      SQLite.with(VideoHistoryTable)
        .save(this.historyInfo)
        .catch((e) => {
          Logger.e(this, 'saveHistoryInfo error=' + JSON.stringify(e))
        })
    }
  }
}