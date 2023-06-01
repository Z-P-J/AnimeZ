import promptAction from '@ohos.promptAction';
import { TaskManagerObserver } from '../download/core/TaskManager'
import M3U8Downloader from '../player/m3u8/M3U8Downloader'
import { ZDownloader } from '../download/ZDownloader'
import EpisodeInfo from '../entity/EpisodeInfo'
import { getTheme } from '../utils/Themes'
import { TaskStatus } from '../download/core/TaskManager'
import { TaskStatusObserver } from '../download/core/TaskManager'
import Logger from '../utils/Logger'
import { FileDownloadTask } from '../download/FileDownloadTask'

@Component
export struct VideoCacheItem {
  @StorageLink('theme') theme: number = 0
  private episodeInfo: EpisodeInfo
  @State downloadTask: FileDownloadTask = null
  @State status: number = -1
  private statusObserver: TaskStatusObserver = {
    onStatusChanged: (task, oldStatus, status) => {
      Logger.d(this, "download onStatusChanged status=" + status)
      this.status = status
    }
  }
  private readonly observer: TaskManagerObserver<FileDownloadTask> = {
    onMissionLoaded: (tasks: FileDownloadTask[]) => {
      let target = tasks.find((task) => {
        return task.taskInfo.originalUrl == this.episodeInfo.link
      })
      if (target) {
        this.downloadTask = target
        this.downloadTask.addStatusObserver(this.statusObserver)
        this.status = target.getStatus()
      }
    },
    onMissionCreateFailed: (task: FileDownloadTask, error: any) => {
      Logger.e(this, 'onMissionCreateFailed id=' + task.getTaskId() + " error=" + JSON.stringify(error))
    },
    onMissionAdd: (task: FileDownloadTask) => {
      Logger.e(this, 'onMissionAdd id=' + task.getTaskId())
      if (task.taskInfo.originalUrl == this.episodeInfo.link) {
        this.downloadTask = task
        this.downloadTask.addStatusObserver(this.statusObserver)
        this.status = task.getStatus()
      }
    },
    onMissionDelete: (task: FileDownloadTask) => {
      if (this.downloadTask && this.downloadTask.getTaskId() == task.getTaskId()) {
        this.downloadTask.removeStatusObserver(this.statusObserver)
        this.downloadTask = null
        this.status = -1
      }
    },
    onMissionFinished: (task: FileDownloadTask) => {
    }
  }

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear')
    ZDownloader.get(M3U8Downloader).addObserver(this.observer)
    ZDownloader.get(M3U8Downloader).loadTasks()
    if (this.downloadTask) {
      this.downloadTask.addStatusObserver(this.statusObserver)
    }
  }

  aboutToDisappear() {
    Logger.e(this, 'aboutToDisappear')
    ZDownloader.get(M3U8Downloader).removeObserver(this.observer)
    if (this.downloadTask) {
      this.downloadTask.removeStatusObserver(this.statusObserver)
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Text(this.episodeInfo.title)
        .textAlign(TextAlign.Center)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontSize(12)
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .maxLines(1)

      if (this.downloadTask) {
        if (this.status == TaskStatus.ERROR) {
          Image($r('app.media.ic_status_error')).width(12).height(12).margin(3)
        } else if (this.status == TaskStatus.COMPLETE) {
          Image($r("app.media.ic_status_finished")).width(12).height(12).margin(3)
        } else {
          Image($r('app.media.ic_status_downloading')).width(12).height(12).margin(3)
        }
      }

    }
    .borderRadius(6)
    .backgroundColor(getTheme(this.theme).background_color_accent)
    .onClick(() => {
      if (!this.downloadTask) {
        this.downloadTask = ZDownloader.get(M3U8Downloader)
          .with(this.episodeInfo.link)
          .setTaskName(this.episodeInfo.desc)
          .setFileName('index.m3u8')
          .setDownloadDir(getContext(this).filesDir + "/download/")
          .build()
        this.downloadTask.start()
      } else {
        promptAction.showToast({ message: '任务已存在' })
      }
    })
  }
}