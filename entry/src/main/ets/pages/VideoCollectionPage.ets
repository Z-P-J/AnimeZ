import { getTheme } from '../utils/Themes';
import { VideoCollectionTable } from '../db/impl/VideoCollectionDao';
import VideoCollectionInfo from '../entity/VideoCollectionInfo';
import router from '@ohos.router'
import SQLite from '../db/SQLite';
import { ViewState } from '../components/StateView';
import StateView from '../components/StateView';
import TitleBar from '../components/TitleBar';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import TransitionHelper from '../utils/TransitionHelper';

@Entry
@Component
struct VideoCollectionPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.LOADING
  @State errorMessage: string = ''
  @State items: VideoCollectionInfo[] = [
//    { src: '11', title: 'Title', coverUrl: '11', accessTime: 0 },
//    { src: '11', title: 'Title', coverUrl: '11', accessTime: 0 },
//    { src: '11', title: 'Title', coverUrl: '11', accessTime: 0 }
  ]

  aboutToAppear() {
    this.loadCollectionList()
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
      TitleBar({ title: '我的收藏' })
      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.HistoryList()
          },
          custom: null,
          onRetry: () => {
            this.loadCollectionList()
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
          this.CollectionItem(item)
        }
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .padding(16)
  }

  @Builder CollectionItem(item: VideoCollectionInfo) {
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
        Text(new Date(item.accessTime).toLocaleDateString())
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
          .fontSize(12)
          .fontColor(getTheme(this.theme).color_text_minor)
      }
      .height('100%')
      .margin(8)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(80)
    .margin({ top: 8, bottom: 8 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/VideoDetailPage', params: {
        url: item.src,
        title: item.title,
        cover: item.coverUrl
      } })
    })
  }

  private loadCollectionList() {
    SQLite.with(VideoCollectionTable)
      .queryAll()
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