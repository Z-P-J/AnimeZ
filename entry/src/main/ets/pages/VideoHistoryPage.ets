import { getTheme } from '../utils/Themes';
import router from '@ohos.router';
import VideoTimeUtils from '../player/VideoTimeUtils';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import SQLite from '../db/SQLite';
import { ViewState } from '../components/StateView';
import StateView from '../components/StateView';
import TitleBar from '../components/TitleBar';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import TransitionHelper from '../utils/TransitionHelper';

@Entry
@Component
struct VideoHistoryPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.CONTENT
  @State errorMessage: string = ''
  @State items: VideoHistoryInfo[] = [
    {
      link: 'link',
      title: 'title',
      currentTime: 10000,
      totalTime: 200000,
      coverUrl: '',
      episodeListIndex: 0,
      episodeIndex: 0,
      episodeName: '第一集',
      videoUrl: '',
      videoProgress: 0
    },
    {
      link: 'link',
      title: 'title',
      currentTime: 10000,
      totalTime: 200000,
      coverUrl: '',
      episodeListIndex: 0,
      episodeIndex: 0,
      episodeName: '第一集',
      videoUrl: '',
      videoProgress: 0
    },
    {
      link: 'link',
      title: 'title',
      currentTime: 10000,
      totalTime: 200000,
      coverUrl: '',
      episodeListIndex: 0,
      episodeIndex: 0,
      episodeName: '第一集',
      videoUrl: '',
      videoProgress: 0
    }
  ]

  aboutToAppear() {
    this.loadHistoryList()
  }

  onPageShow() {
    getTheme(this.theme).initBar()
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
    Column() {
      ImmersionBarSpace()
      TitleBar({ title: '观看历史' })

      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.HistoryList()
          },
          custom: null,
          onRetry: () => {
            this.loadHistoryList()
            return true;
          }
        }
      )
        .width('100%')
        .layoutWeight(1)


      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }

  @Builder HistoryList() {
    List() {
      ForEach(this.items, (item) => {
        ListItem() {
          this.HistoryItem(item)
        }
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .padding(16)
  }

  @Builder HistoryItem(item: VideoHistoryInfo) {
    Row() {
      Image(item.coverUrl)
        .alt($r('app.media.pic_load_failed'))
        .objectFit(ImageFit.Cover)
        .height('100%')
        .aspectRatio(1.5)
        .borderRadius(8)
        .borderColor('#cccccc')

      Column() {
        Text(item.title)
          .alignSelf(ItemAlign.Start)
          .fontColor(getTheme(this.theme).color_text_major)
          .fontSize(16)
        Blank()
        Text(item.episodeName)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
          .fontSize(12)
          .fontColor(getTheme(this.theme).color_text_minor)
        Text(VideoTimeUtils.stringForTime(item.currentTime) + ' / ' + VideoTimeUtils.stringForTime(item.totalTime))
          .alignSelf(ItemAlign.Start)
          .fontSize(12)
          .fontColor(getTheme(this.theme).color_text_minor)
      }
      .height('100%')
      .margin(8)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(80)
    .margin({ top: 8, bottom: 8 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/VideoDetailPage', params: {
        url: item.link,
        title: item.title,
        cover: item.coverUrl
      } })
    })
  }

  private loadHistoryList() {
    SQLite.with(VideoHistoryTable)
      .queryAllByAsc()
      .then((items) => {
        this.items = items
        if (this.items.length == 0) {
          this.state = ViewState.EMPTY
        } else {
          this.state = ViewState.CONTENT
        }
      })
      .catch((e) => {
        this.errorMessage = JSON.stringify(e)
        this.state = ViewState.ERROR
      })
  }
}