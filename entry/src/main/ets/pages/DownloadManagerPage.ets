import EpisodeInfo from '../entity/EpisodeInfo';
import { OnSelectChangeObserver } from '../utils/SelectionManager';
import { SelectionManager } from '../utils/SelectionManager';
import { TaskStatus, TaskStatusObserver } from '../download/core/Task';
import TaskObserver from '../download/core/TaskObserver';
import M3U8Downloader, { M3U8DownloadTask } from '../player/m3u8/M3U8Downloader';
import router from '@ohos.router';
import { TaskManagerObserver } from '../download/core/TaskManager';
import Logger from '../utils/Logger';
import { ZDownloader } from '../download/ZDownloader';
import { getTheme } from '../utils/Themes';
import TransitionHelper from '../utils/TransitionHelper';
import StateView, { ViewState } from '../components/StateView';
import ImmersionBarSpace from '../components/ImmersionBarSpace';

const DOWNLOADER: M3U8Downloader = ZDownloader.get(M3U8Downloader)

/**
 * 下载项
 */
@Component
struct DownloadItem {
  private selectionManager: SelectionManager<M3U8DownloadTask>
  private task: M3U8DownloadTask
  @StorageLink('theme') theme: number = 0
  @State taskName: string = '';
  @State info: string = '已创建';
  @State isFinished: boolean = false;
  @State status: number = TaskStatus.CREATED
  @State canPause: boolean = false;
  @State progress: number = 0;
  @State progressScale: number = 0;
  @State selectionMode: boolean = false
  @State isSelected: boolean = false
  private readonly selectionObserver: OnSelectChangeObserver<M3U8DownloadTask> = {
    onSelectionModeChange: (isSelectionMode: boolean) => {
      this.selectionMode = isSelectionMode
    },
    onSelectChange: (item: M3U8DownloadTask, isSelected) => {
      if (this.task && this.task.getTaskId() == item.getTaskId()) {
        Logger.e(this, 'onSelectChange isSelect=' + isSelected)
        this.isSelected = isSelected
      }
    }
  }
  private readonly observer: TaskObserver = {
    onPreparing: () => {
      Logger.d(this, "download onPreparing");
    },
    onStart: () => {
      Logger.d(this, "download onStart");
    },
    onWaiting: () => {
      Logger.d(this, "download onWaiting");
    },
    onPaused: () => {
      Logger.d(this, "download onPaused");
    },
    onProgress: (totalWorkload: number, completeWorkload: number, progress: number) => {
      let childTasks = this.task.childTaskManager.tasks
      if (childTasks.length > 0) {
        let completeCount = 0
        childTasks.forEach((task) => {
          if (task.isComplete()) {
            completeCount++
          }
        })
        this.progress = completeCount / childTasks.length * 100
      } else {
        this.progress = progress
      }
      Logger.d(this, "download onProgress total: " + totalWorkload + " received: " + completeWorkload + " progress: " + progress);
      this.info = this.getTaskInfo();
      this.showProgressAnim()
    },
    onError: (errorMessage) => {
      Logger.d(this, "download onError: " + errorMessage);
    },
    onComplete: () => {
      Logger.d(this, "download onFinished");
    },
  }
  private statusObserver: TaskStatusObserver = {
    onStatusChanged: (task, oldStatus, status) => {
      Logger.d(this, "download onStatusChanged status=" + status);
      this.info = this.getTaskInfo();
      this.canPause = task.canPause()
      this.status = status
    }
  }

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear')

    this.selectionManager.addObserver(this.selectionObserver)
    this.isSelected = this.selectionManager.isSelect(this.task)

    this.status = this.task.getStatus()
    this.canPause = this.task.canPause()
    this.info = this.getTaskInfo();
    this.isFinished = this.task.isComplete();
    if (this.task.getTaskName()) {
      this.taskName = this.task.getTaskName()
    } else {
      this.taskName = this.task.getFileName()
    }
    this.progress = this.task.getTaskProgress();

    this.task.addObserver(this.observer)
    this.task.addStatusObserver(this.statusObserver)
  }

  aboutToDisappear() {
    Logger.e(this, 'aboutToDisappear')
    this.selectionManager.removeObserver(this.selectionObserver)
    this.task.removeObserver(this.observer)
    this.task.removeStatusObserver(this.statusObserver)
  }

  build() {
    Stack() {
      if (this.status != TaskStatus.COMPLETE) {
        Row()
          .backgroundColor(getTheme(this.theme).background_color_accent)
          .width('100%')
          .height('100%')
          .scale({ x: this.progressScale, centerX: 0 })
          .onAppear(() => {
            this.showProgressAnim(500)
          })
      }
      Row() {
        if (this.selectionMode) {
          Image(this.isSelected ? $r('app.media.ic_selection_selected') : $r('app.media.ic_selection_none'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .fillColor(this.isSelected ? getTheme(this.theme).primary_color : getTheme(this.theme).color_text_minor)
        }
        Image(this.task.videoInfo.coverUrl)
          .alt($r('app.media.pic_load_failed'))
          .height('100%')
          .aspectRatio(1.6)
          .borderRadius(8)
          .margin({ left: 16, right: 16 })
          .objectFit(ImageFit.Cover)
          .shadow({ radius: 12, color: getTheme(this.theme).isDarkTheme ? '#333333' : '#aaaaaa', offsetX: 6, offsetY: 6 })

        Column() {
          Text(this.taskName)
            .fontSize(14)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontWeight(FontWeight.Bold)
            .align(Alignment.Start)
            .width('100%')
          Text(this.info)
            .fontSize(10)
            .fontColor(getTheme(this.theme).color_text_minor)
            .align(Alignment.Start)
            .width('100%')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .height('100%')
        .margin({ right: 16 })

        if (this.status != TaskStatus.COMPLETE) {
          Image(this.canPause ? $r('app.media.ic_download_pause') : $r('app.media.ic_download_resume'))
            .width(28)
            .height(28)
            .margin({ right: 14 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              if (this.task.canPause()) {
                this.task.pause()
              } else if (this.task.canStart()) {
                this.task.addObserver(this.observer)
                this.task.addStatusObserver(this.statusObserver)
                this.task.start()
              }
            })
        }

      }
      .width('100%')
      .height('100%')
      .padding({ top: 12, bottom: 12 })
    }
    .height('100%')
    .height(80)
  }

  private showProgressAnim(duration: number = 250) {
    animateTo({
      duration: duration,
      curve: Curve.ExtremeDeceleration,
      iterations: 1,
      playMode: PlayMode.Normal
    }, () => {
      this.progressScale = this.progress / 100
    })
  }

  getActionIcon(): Resource {
    if (this.task.canPause()) {
      return $r('app.media.ic_download_pause');
    } else {
      return $r('app.media.ic_download_resume');
    }
  }

  getActionIconString(): string {
    if (this.task.canPause()) {
      return 'app.media.ic_download_pause';
    } else {
      return 'app.media.ic_download_resume';
    }
  }

  getTaskInfo() {
    let status = this.task.getStatus()
    Logger.e(this, 'getTaskInfo status=' + status)
    if (status == TaskStatus.CREATED) {
      return '已暂停';
    } else if (status == TaskStatus.PREPARING) {
      return '准备中';
    } else if (status == TaskStatus.WAITING) {
      return '等待中';
    } else if (status == TaskStatus.PROCESSING) {
      return this.task.getFormatTotalSize() + ' / ' + this.task.getFormatReceivedSize() + ' ' + this.task.getFormatProgress();
    } else if (status == TaskStatus.PAUSED) {
      return '已暂停';
    } else if (status == TaskStatus.COMPLETE) {
      return '已完成';
    } else {
      if (this.task.taskInfo.message) {
        return '出错了：' + this.task.taskInfo.message;
      }
      return '出错了';
    }
  }
}

/**
 * 下载列表
 */
@Component
struct DownloadManagerList {
  private selectionManager: SelectionManager<M3U8DownloadTask>
  @StorageLink('theme') theme: number = 0
  @Link tasks: M3U8DownloadTask[]
  @State selections: number[] = []

  aboutToAppear() {

  }

  build() {
    Column() {
      List() {
        ForEach(this.tasks.map((task, i) => {
          return i
        }), (i) => {
          ListItem() {
            DownloadItem({ selectionManager: this.selectionManager, task: this.tasks[i] })
          }
          .onClick(() => {
            let task = this.tasks[i]
            Logger.e(this, 'isSelectionMode=' + this.selectionManager.isSelectionMode())
            if (this.selectionManager.isSelectionMode()) {
              this.selectionManager.toggleSelectItem(task)
              return
            }
            if (task.isComplete()) {
              let episode: EpisodeInfo = {
                title: task.getTaskName(),
                desc: task.getTaskName(),
                link: task.getOriginalUrl(),
                videoUrl: task.getLocalM3U8Path()
              }
              router.pushUrl({ url: 'pages/LocalVideoPlayerPage', params: { episode: episode } })
            }
          })
          .gesture(LongPressGesture({ repeat: false })
            .onAction((event) => {
              Logger.e(this, 'onLongPress')
              // 长按多选
              if (!this.selectionManager.isSelectionMode()) {
                this.selectionManager.toggleSelectionMode()
              }
              this.selectionManager.toggleSelectItem(this.tasks[i])
            })
          )
        })

        // TODO 这样写竟然报错？？？？
        //        ForEach(this.tasks, (task: M3U8DownloadTask) => {
        //          ListItem() {
        //            DownloadItem({ selectMode: $selectMode, task: task })
        //          }
        //          //          .selectable(true)
        //          .onSelect((isSelected) => {
        //            Logger.e(this, 'isSelected=' + isSelected)
        //          })
        //          .onClick(() => {
        //            if (task.isComplete()) {
        //              router.pushUrl({url: 'pages/LocalVideoPlayerPage', params: {video_path: task.getLocalM3u8Path()}})
        //            }
        //          })
        //          .gesture(LongPressGesture({ repeat: false })
        //            .onActionEnd(() => {
        //              Logger.e(this, 'onLongPress')
        //              this.selectMode = !this.selectMode
        //            }))
        //        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 下载管理页
 */
@Entry
@Component
struct DownloadManagerPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.LOADING
  @State errorMessage: string = ''
  @State selectMode: boolean = false
  @State selectCount: number = 0
  @State hasSelectAll: boolean = false
  @State tasks: M3U8DownloadTask[] = []
  @State taskCount: number = 0
  @State isAllComplete: boolean = false
  @State canPauseAll: boolean = false
  private readonly selectionManager: SelectionManager<M3U8DownloadTask> = new SelectionManager<M3U8DownloadTask>()

  private readonly observer: TaskManagerObserver<M3U8DownloadTask> = {
    onTaskLoaded: (tasks: M3U8DownloadTask[]) => {
      this.tasks = this.tasks.concat(tasks).reverse()
      Logger.e(this, 'onMissionLoaded tasks len=' + tasks.length)
      this.onTasksChanged()
    },
    onTaskCreateFailed: (task: M3U8DownloadTask, error: any) => {
      Logger.e(this, 'onMissionCreateFailed id=' + task.getTaskId() + " error=" + JSON.stringify(error))
    },
    onTaskAdd: (task: M3U8DownloadTask) => {
      Logger.e(this, 'onMissionAdd id=' + task.getTaskId())
      this.tasks.push(task)
      this.onTasksChanged()
    },
    onTaskRemove: (task: M3U8DownloadTask) => {
      this.tasks = this.tasks.filter((item) => {
        return item.getTaskId() != task.getTaskId()
      })
      this.onTasksChanged()
    },
    onTaskComplete: (task: M3U8DownloadTask) => {
      Logger.e(this, 'onMissionFinished id=' + task.getTaskId())
      this.onTasksChanged()
    },
    onTaskStatusChanged: (task: M3U8DownloadTask, oldStatus: TaskStatus, newStatus: TaskStatus) => {
      this.onTasksChanged()
    }
  }
  private readonly selectionObserver: OnSelectChangeObserver<M3U8DownloadTask> = {
    onSelectionModeChange: (isSelectionMode: boolean) => {
      this.selectMode = isSelectionMode
      if (!this.selectMode) {
        this.selectCount = 0
      }
    },
    onSelectChange: (item: M3U8DownloadTask, isSelected) => {
      this.selectCount = this.selectionManager.getSelectionCount()
      this.hasSelectAll = this.selectCount == this.tasks.length
    }
  }

  aboutToAppear() {
    getTheme(this.theme).initBar()

    DOWNLOADER.addObserver(this.observer)

    DOWNLOADER.loadTasks()

    //    this.downloadTask = DOWNLOADER.with("https://ukzy.ukubf4.com/20230402/ilm8IR50/index.m3u8")
    //      .setName("index.m3u8")
    //      .setDownloadDir(getContext(this).filesDir + "/download/")
    //      .build()
    //    this.downloadTask.start()

    this.selectionManager.addObserver(this.selectionObserver)
    this.selectMode = this.selectionManager.isSelectionMode()
  }

  aboutToDisappear() {
    this.selectionManager.removeObserver(this.selectionObserver)
    DOWNLOADER.removeObserver(this.observer)
  }

  onBackPress() {
    if (this.selectionManager.isSelectionMode()) {
      this.selectionManager.toggleSelectionMode()
      return true
    }
    return false
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
          Text('下载管理')
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

      if (this.state == ViewState.CONTENT) {
        Row() {
          if (this.isAllComplete) {
            Text() {
              Span(`${this.taskCount} `)
                .fontSize(14)
                .fontColor(getTheme(this.theme).primary_color)
              Span('已缓存')
                .fontSize(14)
                .fontColor(getTheme(this.theme).color_text_major)
            }
            .height(32)
          } else {
            Row() {
              Text(this.canPauseAll ? '全部暂停' : '全部开始')
                .margin({ right: 4 })
                .fontSize(12)
                .fontColor(this.selectMode ? getTheme(this.theme).color_text_minor : getTheme(this.theme)
                                                                                       .color_text_major)
              Image(this.canPauseAll ? $r('app.media.ic_pause') : $r('app.media.ic_download2'))
                .width(16)
                .height(16)
                .fillColor(this.selectMode ? getTheme(this.theme).color_text_minor : getTheme(this.theme)
                                                                                       .color_text_major)
            }
            .padding({ top: 8, bottom: 8 })
            .onClick(() => {
              if (this.selectMode) {
                return
              }
              if (this.canPauseAll) {
                DOWNLOADER.pauseAll()
              } else {
                DOWNLOADER.startAll()
              }
            })
          }
        }
        .justifyContent(FlexAlign.End)
        .padding({ left: 16, right: 16 })
        .width('100%')

        DownloadManagerList({ tasks: $tasks, selectionManager: this.selectionManager })
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
                this.selectionManager.selectItems(this.tasks)
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
                    title: '移除下载任务',
                    message: `确认移除选中的${this.selectCount}项下载任务？`,
                    primaryButton: {
                      value: '取消',
                      action: () => {
                      }
                    },
                    secondaryButton: {
                      value: '确定',
                      fontColor: Color.Red,
                      action: () => {
                        this.selectionManager.getSelections().forEach((task) => {
                          task.delete()
                        })
                        this.selectionManager.toggleSelectionMode()
                      }
                    }
                  }
                )

              })
          }
          .width('100%')
          .height(42)
        }
      } else {
        StateView(
          {
            state: $state,
            errorMessage: $errorMessage,
            content: null,
            custom: null,
            onRetry: () => {
              this.loadDownloadItems()
              return true;
            }
          }
        )
          .width('100%')
          .layoutWeight(1)
      }
      ImmersionBarSpace()
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .width('100%')
    .height('100%')
  }

  private onTasksChanged() {
    Logger.e(this, 'onTasksChanged len=' + this.tasks.length)
    if (this.tasks.length > 0) {
      this.state = ViewState.CONTENT
    } else {
      this.state = ViewState.EMPTY
    }

    this.taskCount = DOWNLOADER.tasks.length
    this.isAllComplete = DOWNLOADER.isComplete()
    this.canPauseAll = DOWNLOADER.canPauseAll()

  }

  private loadDownloadItems() {

  }
}