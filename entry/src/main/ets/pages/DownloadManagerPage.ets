import DownloadTaskInfo from '../download/DownloadTaskInfo';
import { TaskManagerObserver } from '../download/core/TaskManager';
import Logger from '../utils/Logger';
import Task from '../download/core/Task';
import { DownloadItem } from '../components/DownloadItem';
import { FileDownloadTask } from '../download/FileDownloadTask';
import M3U8Downloader from '../player/m3u8/M3U8Downloader';
import { ZDownloader } from '../download/ZDownloader';
import { getTheme } from '../utils/Themes';
import TransitionHelper from '../utils/TransitionHelper';
import { ViewState } from '../components/StateView';
import StateView from '../components/StateView';
import TitleBar from '../components/TitleBar';
import ImmersionBarSpace from '../components/ImmersionBarSpace';

const DOWNLOADER: M3U8Downloader = ZDownloader.get(M3U8Downloader)

@Entry
@Component
struct DownloadManagerPage {
  @StorageLink('theme') theme: number = 0
  @State state: number = ViewState.LOADING
  @State errorMessage: string = ''
  @State selectMode: boolean = false
  @State tasks: FileDownloadTask[] = [
  //    new DownloadTaskInfo(100, 1000)

//    new FileDownloadTask(null, new DownloadTaskInfo(100, 1000))

  ]

  // TODO 测试数据
  testData = [
    {name: '最强主宰 动态漫画 第41集', url: 'https://ukzy.ukubf4.com/20230514/n77WsZgB/index.m3u8'},
    {name: '最强主宰 动态漫画 第40集', url: 'https://ukzy.ukubf4.com/20230509/esQzkKyr/index.m3u8'},
    {name: '最强主宰 动态漫画 第39集', url: 'https://ukzy.ukubf4.com/20230507/T3yYyWxB/index.m3u8'},
    {name: '最强主宰 动态漫画 第29集', url: 'https://ukzy.ukubf4.com/20230402/ilm8IR50/index.m3u8'}
  ]

  private readonly observer: TaskManagerObserver<FileDownloadTask> = {
    onMissionLoaded: (tasks: FileDownloadTask[]) => {
      this.tasks = this.tasks.concat(tasks)
      Logger.e(this, 'onMissionLoaded tasks len=' + tasks.length)
      this.onTasksChanged()
    },
    onMissionCreateFailed: (task: FileDownloadTask, error: any) => {
      Logger.e(this, 'onMissionCreateFailed id=' + task.getTaskId() + " error=" + JSON.stringify(error))
    },
    onMissionAdd: (task: FileDownloadTask) => {
      Logger.e(this, 'onMissionAdd id=' + task.getTaskId())
      this.tasks.push(task)
      this.onTasksChanged()
    },
    onMissionDelete: (task: FileDownloadTask) => {

      this.tasks = this.tasks.filter((item) => {
        return item != task
      })
      this.onTasksChanged()

//      let index = this.tasks.indexOf(task)
//      Logger.e(this, 'onMissionDelete id=' + task.getTaskId() + " index=" + index)
//      if (index >= 0) {
//        this.tasks.slice(index, 1)
//        this.onTasksChanged()
//      }
    },
    onMissionFinished: (task: FileDownloadTask) => {
      Logger.e(this, 'onMissionFinished id=' + task.getTaskId())
    }
  }

  aboutToAppear() {

    DOWNLOADER.addObserver(this.observer)

    DOWNLOADER.loadTasks()

    //    this.downloadTask = DOWNLOADER.with("https://ukzy.ukubf4.com/20230402/ilm8IR50/index.m3u8")
    //      .setName("index.m3u8")
    //      .setDownloadDir(getContext(this).filesDir + "/download/")
    //      .build()
    //    this.downloadTask.start()
  }

  aboutToDisappear() {
    DOWNLOADER.removeObserver(this.observer)
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
      TitleBar({ title: '下载管理' })

      Row() {

        Button('添加任务')
          .onClick(() => {

            if (this.testData.length > 0) {
              let data = this.testData.splice(0, 1)[0]
              Logger.e(this, 'add task data=' + JSON.stringify(data))
              let url = data['url']
              let downloadTask = DOWNLOADER.with(url)
                .setTaskName(data['name'])
                .setFileName("index.m3u8")
                .setDownloadDir(getContext(this).filesDir + "/download/")
                .build()
              downloadTask.start()
            }

            //            let url = "https://ukzy.ukubf4.com/20230402/ilm8IR50/index.m3u8"
            //            let downloadTask = DOWNLOADER.with(url)
            //              .setTaskName("index.m3u8")
            //              .setDownloadDir(getContext(this).filesDir + "/download/" + CryptoJS.MD5(url))
            //              .build()
            //            downloadTask.start()
          })

        Button('移除任务')
          .onClick(() => {
            Logger.e(this, 'delete task len=' + this.tasks.length)
            if (this.tasks.length > 0) {
              this.tasks[0].delete()
            }
          })
      }

      StateView(
        {
          state: $state,
          errorMessage: $errorMessage,
          content: () => {
            this.Content()
          },
          custom: null,
          onRetry: () => {
            this.loadDownloadItems()
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

  @Builder Content() {
    Column() {
      List() {
        ForEach(this.tasks.map((task, i) => {
          return i
        }), (i) => {
          ListItem() {
            DownloadItem({ task: this.tasks[i] })
              .margin(16)
          }
          .selectable(true)
          .onSelect((isSelected) => {
            Logger.e(this, 'isSelected=' + isSelected)
          })
          .gesture(LongPressGesture({ repeat: false })
            .onActionEnd(() => {
              Logger.e(this, 'onLongPress')
              this.selectMode = !this.selectMode
            }))
        })
      }
      .width('100%')
      .height('100%')
    }
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
  }

  private loadDownloadItems() {

  }
}