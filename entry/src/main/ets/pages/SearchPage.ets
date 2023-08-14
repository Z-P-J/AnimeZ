import DataSourceManager from '../api/DataSourceManager';
import { getTheme } from '../utils/Themes';
import TransitionHelper from '../utils/TransitionHelper';
import Logger from '../utils/Logger';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { SearchHistoryTable } from '../db/impl/SearchHistoryDao';
import SQLite from '../db/SQLite';
import { SearchHistoryInfo } from '../entity/SearchHistoryInfo';
import router from '@ohos.router';
import DataSource from '../api/DataSource';
import { ViewState } from '../components/StateView';
import { VideoList } from '../components/VideoList';
import VideoInfo from '../entity/VideoInfo';
import StateView from '../components/StateView';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SearchPage {
  @StorageLink('theme') theme: number = 0
  @State videoList: VideoInfo[] = []
  @State searchHistoryList: SearchHistoryInfo[] = [
  //    { id: 0, keyword: '1' }, { id: 0, keyword: '122222' }, { id: 0, keyword: '156' },
  //    { id: 0, keyword: '14656' }, { id: 0, keyword: '12354' }, { id: 0, keyword: '1' },
  //    { id: 0, keyword: '1' }, { id: 0, keyword: '1111111112' }, { id: 0, keyword: '222222' }
  ]
  @State searchRecommends: string[] = ['进击的巨人', '电锯人', '鲁路修', '命运石之门', '回复术士', '天降之物']
  @State state: number = ViewState.CUSTOM
  @State errorMessage: string = ''
  @State keyword: string = ''

  aboutToAppear() {
    SQLite.with(SearchHistoryTable)
      .queryAll()
      .then((list) => {
        this.searchHistoryList = list
      })
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
      this.SearchBar()
      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.content()
          },
          custom: () => {
            this.SearchHistory()
          },
          onRetry: () => {
            this.doSearch(this.keyword)
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

  @Builder content() {
    VideoList({ videoList: this.videoList }).height('100%').padding(16)
  }

  @Builder SearchBar() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .margin({ left: 12 })
        .fillColor(getTheme(this.theme).color_text_major)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          router.back()
        })
      TextInput({ placeholder: '输入关键字...' })
        .placeholderFont({ size: 14, weight: 300 })
        .placeholderColor('#817977')
        .fontColor(getTheme(this.theme).color_text_major)
        .onChange((value) => {
          this.keyword = value
        })
        .onSubmit(() => {
          this.doSearch(this.keyword)
        })
        .height(36)
        .margin({ left: 12, right: 12 })
        .backgroundColor(getTheme(this.theme).background_color)
        .layoutWeight(1)
      Text('搜索')
        .fontSize(16)
        .fontColor(getTheme(this.theme).primary_color)
          //        .fontWeight(300)
        .margin({ right: 16 })
        .onClick(() => {
          this.doSearch(this.keyword)
        })
    }
    .height(56)
    .width('100%')
  }

  @Builder Bar(title: string, showButton: boolean = true) {
    Row() {
      Row()
        .height(14)
        .width(6)
        .margin({ right: 2 })
        .borderRadius(4)
        .backgroundColor(getTheme(this.theme).primary_color)
      Text(title)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontSize(16)
        .fontWeight(500)

      Blank()

      if (showButton) {
        Image($r('app.media.ic_delete'))
          .width(20)
          .height(20)
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            this.clearHistory()
          })
      }
    }
    .alignSelf(ItemAlign.Start)
    .width('100%')
    .padding({ left: 16, top: 16, right: 16, bottom: 8 })
  }

  @Builder SearchHistory() {
    Scroll() {
      Column() {
        if (this.searchHistoryList.length > 0) {
          this.Bar("搜索历史")
          Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
            ForEach(this.searchHistoryList, (item: SearchHistoryInfo) => {
              Text(item.keyword)
                .textAlign(TextAlign.Center)
                .backgroundColor(getTheme(this.theme).background_color)
                .fontColor(getTheme(this.theme).color_text_major)
                .fontWeight(300)
                .fontSize(14)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .borderRadius(4)
                .margin(6)
                .constraintSize({
                  minWidth: '15%',
                  maxWidth: '50%'
                })
                .onClick(() => {
                  this.doSearch(item.keyword)
                })

            })
          }
          .margin(6)
        }

        this.Bar("搜索推荐", false)
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
          ForEach(this.searchRecommends, (item: string) => {
            Text(item)
              .width('45%')
              .textAlign(TextAlign.Start)
              .fontColor(getTheme(this.theme).color_text_major)
              .fontWeight(300)
              .fontSize(14)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ top: 2, bottom: 2 })
              .margin(6)
              .onClick(() => {
                this.doSearch(item)
              })
          })
        }
        .margin(6)

        ImmersionBarSpace()
      }
      .constraintSize({
        minHeight: '100%'
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
  }

  private doSearch(keyword: string) {
    Logger.e(this, 'doSearch keyword=' + keyword)
    this.keyword = keyword
    if (this.keyword.length == 0) {
      promptAction.showToast({ message: '请输入关键词' })
      return
    }
    this.state = ViewState.LOADING
    SQLite.with(SearchHistoryTable).saveOrUpdate(keyword)
      .then((result) => {
        Logger.e(this,  'saveOrUpdate result=' + result)
      })
      .catch((e) => {
        Logger.e(this,  'saveOrUpdate e=' + JSON.stringify(e))
      })
    // TODO 支持更多数据源
    DataSourceManager.getCurrentSource().search(keyword, 1)
      .then((videoList) => {
        this.videoList = videoList
        if (this.videoList.length == 0) {
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

  private clearHistory() {
    AlertDialog.show(
      {
        title: '清空搜索历史',
        message: '确认清空搜索历史记录？',
        primaryButton: {
          value: '取消',
          action: () => {
          }
        },
        secondaryButton: {
          value: '确定',
          fontColor: Color.Red,
          action: () => {
            SQLite.with(SearchHistoryTable)
              .clearTable()
            this.searchHistoryList = []
          }
        }
      }
    )
  }
}