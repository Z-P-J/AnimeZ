import { HISTORY_CHANGED_EVENT } from '../utils/EventBus';
import Logger from '../utils/Logger';
import { OnSelectChangeObserver, SelectionManager } from '../utils/SelectionManager';
import { getTheme } from '../utils/Themes';
import router from '@ohos.router';
import VideoTimeUtils from '../player/VideoTimeUtils';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import SQLite from '../db/SQLite';
import StateView, { ViewState } from '../components/StateView';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import { OPTIONS_TRANSITION_POP, OPTIONS_TRANSITION_PUSH } from '../utils/TransitionHelper';

/**
 * 收藏项
 */
@Component
struct HistoryItem {
  @StorageLink('theme') theme: number = 0
  @State selectionMode: boolean = false
  @State isSelected: boolean = false

  private selectionManager: SelectionManager<VideoHistoryInfo>
  private item: VideoHistoryInfo
  @State selectionIconMargin: number = 0
  @State selectionIconSize: number = 0
  private readonly selectionObserver: OnSelectChangeObserver<VideoHistoryInfo> = {
    onSelectionModeChange: (isSelectionMode: boolean) => {
      if (isSelectionMode) {
        this.selectionMode = true
        animateTo({
          duration: 360,
          curve: Curve.ExtremeDeceleration,
          iterations: 1,
          playMode: PlayMode.Normal
        }, () => {
          this.selectionIconSize = 24
          this.selectionIconMargin = 16
        })
      } else {
        animateTo({
          duration: 360,
          curve: Curve.ExtremeDeceleration,
          iterations: 1,
          playMode: PlayMode.Normal,
          onFinish: () => {
            this.selectionMode = false
          }
        }, () => {
          this.selectionIconSize = 0
          this.selectionIconMargin = 0
        })
      }
    },
    onSelectChange: (item: VideoHistoryInfo, isSelected) => {
      if (this.item && this.item.link == item.link) {
        Logger.e(this, 'onSelectChange isSelect=' + isSelected)
        this.isSelected = isSelected
      }
    }
  }

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear')
    this.selectionManager.addObserver(this.selectionObserver)
    this.isSelected = this.selectionManager.isSelect(this.item)
  }

  aboutToDisappear() {
    Logger.e(this, 'aboutToDisappear')
    this.selectionManager.removeObserver(this.selectionObserver)
  }


  build() {
    Row() {
      Image(this.isSelected ? $r('app.media.ic_selection_selected') : $r('app.media.ic_selection_none'))
        .width(this.selectionIconSize)
        .height(this.selectionIconSize)
        .margin({ left: this.selectionIconMargin })
        .visibility(this.selectionMode ? Visibility.Visible : Visibility.None)
        .fillColor(this.isSelected ? getTheme(this.theme).primary_color : getTheme(this.theme).color_text_minor)
      Image(this.item.coverUrl)
        .alt($r('app.media.pic_load_failed'))
        .objectFit(ImageFit.Cover)
        .height('100%')
        .margin({left: 16})
        .aspectRatio(1.5)
        .borderRadius(8)
        .shadow({ radius: 12, color: getTheme(this.theme).isDarkTheme ? '#000000' : '#aaaaaa', offsetX: 6, offsetY: 6 })

      Column() {
        Text(this.item.title)
          .alignSelf(ItemAlign.Start)
          .fontColor(getTheme(this.theme).color_text_major)
          .fontSize(16)
        Blank()
        Text(this.item.episodeName)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
          .fontSize(12)
          .fontColor(getTheme(this.theme).color_text_minor)
        Text(VideoTimeUtils.stringForTime(this.item.currentTime) + ' / ' + VideoTimeUtils.stringForTime(this.item.totalTime))
          .alignSelf(ItemAlign.Start)
          .fontSize(12)
          .fontColor(getTheme(this.theme).color_text_minor)
      }
      .height('100%')
      .margin({ left: 12, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(80)
  }
}

@Entry
@Component
struct VideoHistoryPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.CONTENT
  @State errorMessage: string = ''
  @State items: VideoHistoryInfo[] = []
  @State selectMode: boolean = false
  @State selectCount: number = 0
  @State hasSelectAll: boolean = false
  private readonly selectionManager: SelectionManager<VideoHistoryInfo> = new SelectionManager<VideoHistoryInfo>()
  private readonly selectionObserver: OnSelectChangeObserver<VideoHistoryInfo> = {
    onSelectionModeChange: (isSelectionMode: boolean) => {
      this.selectMode = isSelectionMode
      if (!this.selectMode) {
        this.selectCount = 0
      }
    },
    onSelectChange: (item: VideoHistoryInfo, isSelected) => {
      this.selectCount = this.selectionManager.getSelectionCount()
      this.hasSelectAll = this.selectCount == this.items.length
    }
  }

  aboutToAppear() {
    this.selectionManager.addObserver(this.selectionObserver)
    this.selectMode = this.selectionManager.isSelectionMode()
  }

  aboutToDisappear() {
    this.selectionManager.removeObserver(this.selectionObserver)
  }

  onBackPress() {
    if (this.selectionManager.isSelectionMode()) {
      this.selectionManager.toggleSelectionMode()
      return true
    }
    return false
  }

  onPageShow() {
    getTheme(this.theme).initBar()
    this.loadHistoryList()
  }

  pageTransition() {
    PageTransitionEnter(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Right)
    PageTransitionEnter(OPTIONS_TRANSITION_POP).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_PUSH).slide(SlideEffect.Left)
    PageTransitionExit(OPTIONS_TRANSITION_POP).slide(SlideEffect.Right)
  }

  build() {
    Column() {
      ImmersionBarSpace()
      Column() {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .objectFit(ImageFit.Contain)
            .fillColor(getTheme(this.theme).color_text_major)
            .onClick(() => {
              router.back()
            })
          Text('观看历史')
            .fontColor(getTheme(this.theme).color_text_major)
            .fontSize(20)
            .fontWeight(500)
            .layoutWeight(1)
            .margin({ left: 16 })
            .align(Alignment.Start)
          Blank()

          if (this.state == ViewState.CONTENT) {
            Image(this.selectMode ? $r('app.media.ic_edit_cancel') : $r('app.media.ic_edit'))
              .width(24)
              .height(24)
              .margin({ right: 16 })
              .objectFit(ImageFit.Contain)
              .fillColor(getTheme(this.theme).color_text_major)
              .onClick(() => {
                this.selectionManager.toggleSelectionMode()
              })
          }
        }
        .height(56)
        .width('100%')
      }

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
      if (this.selectMode) {
        Row() {
          Row() {
            Image(this.hasSelectAll ? $r('app.media.ic_selection_selected') : $r('app.media.ic_selection_none'))
              .width(24)
              .height(24)
              .fillColor(this.hasSelectAll ? $r('app.color.primary_color_accent') : getTheme(this.theme)
                                                                                      .color_text_minor)
            Text(this.hasSelectAll ? '全不选' : '全选')
              .fontColor(getTheme(this.theme).color_text_major)
              .fontSize(14)
              .margin({ left: 8 })
          }
          .margin({ left: 16 })
          .onClick(() => {
            if (this.hasSelectAll) {
              this.selectionManager.clearSelections()
            } else {
              this.selectionManager.selectItems(this.items)
            }
          })

          Blank()
          Text(`删除(${this.selectCount})`)
            .fontColor(this.selectCount == 0 ? getTheme(this.theme).color_text_minor : Color.Red)
            .fontSize(14)
            .margin({ right: 16 })
            .onClick(() => {
              if (this.selectCount == 0) {
                return
              }

              AlertDialog.show(
                {
                  title: '移除收藏动漫',
                  message: `确认移除选中的${this.selectCount}项收藏动漫？`,
                  primaryButton: {
                    value: '取消',
                    action: () => {
                    }
                  },
                  secondaryButton: {
                    value: '确定',
                    fontColor: Color.Red,
                    action: () => {
                      SQLite.with(VideoHistoryTable)
                        .deleteItems(...this.selectionManager.getSelections())
                        .then((results) => {
                          Logger.e(this, 'delete results=' + JSON.stringify(results))
                          HISTORY_CHANGED_EVENT.emit()
                          this.selectionManager.toggleSelectionMode()
                          this.loadHistoryList()
                        })
                        .catch((e) => {
                          Logger.e(this, 'delete failed! e=' + JSON.stringify(e))
                        })
                    }
                  }
                }
              )

            })
        }
        .width('100%')
        .height(42)
      }
      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .width('100%')
    .height('100%')
  }

  @Builder HistoryList() {
    List({space: 16}) {
      ForEach(this.items, (item: VideoHistoryInfo) => {
        ListItem() {
          HistoryItem({selectionManager: this.selectionManager, item: item})
        }
        .onClick(() => {
          if (this.selectionManager.isSelectionMode()) {
            this.selectionManager.toggleSelectItem(item)
            return
          }
          router.pushUrl({ url: 'pages/VideoDetailPage', params: {
            url: item.link,
            sourceKey: item.sourceKey,
            title: item.title,
            cover: item.coverUrl
          } })
        })
        .gesture(LongPressGesture({ repeat: false })
          .onAction((event) => {
            Logger.e(this, 'onLongPress')
            // 长按多选
            if (!this.selectionManager.isSelectionMode()) {
              this.selectionManager.toggleSelectionMode()
            }
            this.selectionManager.toggleSelectItem(item)
          })
        )
      })
    }
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .padding({top: 16, bottom: 16})
  }

  private loadHistoryList() {
    SQLite.with(VideoHistoryTable)
      .queryAllByAccessTimeDesc()
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