import { TaskStatusObserver } from '../download/core/Task';
import { TaskStatus } from '../download/core/Task';
import Logger from '../utils/Logger';
import TaskObserver from '../download/core/TaskObserver';
import { FileDownloadTask } from '../download/FileDownloadTask';

@Component
export struct DownloadItem {
  private task: FileDownloadTask
  @State taskName: string = '';
  @State info: string = '已创建';
  @State isFinished: boolean = false;
  @State status: number = TaskStatus.CREATED
  @State canPause: boolean = false;
  @State progress: number = 0;

  @Link selectMode: boolean

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
    onProgress: (totalSize: number, receivedSize: number, progress: number) => {
      this.progress = progress
      Logger.d(this, "download onProgress total: " + totalSize + " received: " + receivedSize + " progress: " + progress);
      this.info = this.getTaskInfo();
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
      if (task.canStart()) {
        this.task.removeStatusObserver(this.statusObserver)
        this.task.removeObserver(this.observer)
      }
    }
  }

  aboutToAppear() {
    Logger.e(this, 'aboutToAppear')
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

    if (this.task.isRunning()) {
      this.task.addObserver(this.observer)
      this.task.addStatusObserver(this.statusObserver)
    }
  }

  aboutToDisappear() {
    Logger.e(this, 'aboutToDisappear')
    this.task.removeObserver(this.observer)
    this.task.removeStatusObserver(this.statusObserver)
  }

  build() {
    Row() {
      Image($r('app.media.icon'))
        .width(20)
        .height(20)
        .margin({ left: 16, right: 16 })
        .objectFit(ImageFit.Contain)

      Column() {
        Text(this.taskName)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .align(Alignment.Start)
          .width('100%')

        Progress({ value: this.progress, type: ProgressType.Linear })
          .margin({ top: 4, bottom: 4 })
          .width('100%')

        Text(this.info)
          .fontSize(10)
          .align(Alignment.Start)
          .width('100%')
      }
      .layoutWeight(1)
      .margin({ top: 10, bottom: 10, right: 14 })

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
      Blank()
    }
    .width('100%')
    .backgroundColor(this.selectMode ? Color.Blue : Color.White)
    .borderRadius(16)
    .padding(8)
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