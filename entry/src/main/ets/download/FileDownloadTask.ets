import { TaskStatus } from './core/Task';
import fs from '@ohos.file.fs'
import TaskManager from './core/TaskManager'
import DownloadTaskInfo from './DownloadTaskInfo'
import { AbsTask } from './core/Task'
import Logger from '../utils/Logger'
import http from '@ohos.net.http'
import { DownloadUtils } from './DownloadUtils'
import util from '@ohos.util'

export class FileDownloadTask<T extends DownloadTaskInfo = DownloadTaskInfo> extends AbsTask<T> {
  protected redirectCount: number = 0

  constructor(manager: TaskManager, taskInfo: T) {
    super(manager, taskInfo)
  }

  getOriginalUrl(): string {
    return this.taskInfo.originalUrl
  }

  getUrl(): string {
    return this.taskInfo.url
  }

  getTaskName() {
    if (this.taskInfo.taskName) {
      return this.taskInfo.taskName
    }
    return null
  }

  getFilePath(): string {
    return this.taskInfo.downloadDir + '/' + this.taskInfo.fileName
  }

  getFileName() {
    if (this.taskInfo.fileName) {
      return this.taskInfo.fileName
    }
    return 'Unknown File'
  }

  getDownloadDir() {
    return this.taskInfo.downloadDir
  }

  getFormatTotalSize() {
    return DownloadUtils.formatFileSize(this.getTotalWorkload())
  }

  getFormatReceivedSize() {
    return DownloadUtils.formatFileSize(this.getCompleteWorkload())
  }

  getFormatProgress() {
    return DownloadUtils.formatProgress(this.getTaskProgress())
  }

  doInit() {
    Logger.w(this, 'doInit redirectCount=' + this.redirectCount)
    if (this.redirectCount > 10) {
      this.statusManager.onError('to many redirect!')
      return
    }

    let httpRequest = http.createHttp()
    httpRequest.request(this.taskInfo.url, {
      method: http.RequestMethod.HEAD,
      readTimeout: 20000,
      connectTimeout: 20000,
      header: { 'range': 'bytes=0-' },
      expectDataType: http.HttpDataType.ARRAY_BUFFER
    }, (err, data) => {
      this.doPrepare(err, data)
    })
  }

  doPrepare(err, data) {
    if (data) {
      Logger.w(this, 'doInit data=' + JSON.stringify(data))
      let code = data.responseCode
      if (code < 300) {
        this.taskInfo.blockDownload = code === http.ResponseCode.PARTIAL
        this.observerDispatcher.progressManager.onInitSize(parseInt(data.header['content-length']))
        if (!this.taskInfo.fileName) {
          this.taskInfo.fileName = DownloadUtils.guessFileName(
            this.taskInfo.url, data.header['content-disposition'], data.header['content-type'])
        }
        this.taskInfo.prepared = true
        this.manager.process(this)
      } else if (code < 400) {
        // 重定向
        this.redirectCount++
        let location = data.header['location']
        this.taskInfo.url = location
        this.doInit()
      } else {
        // 请求出错了
        this.statusManager.onError('request error! responseCode is ' + code)
      }
    } else {
      Logger.w(this, 'doInit err=' + JSON.stringify(err))
      this.statusManager.onError(err.message)
    }
  }

  doWaiting() {
    // do nothing
    Logger.d(this, 'doWaiting')
  }

  doPause() {
    // do noting
    Logger.d(this, 'doPause')
  }

  doDelete() {
    fs.unlink(this.getFilePath())
      .then(() => {
        Logger.e(this, 'doDelete success')
      })
      .catch((e) => {
        // TODO error
        Logger.e(this, 'doDelete failed! e=' + JSON.stringify(e))
      })
  }

  //    abstract doStart()

  doStart() {
    let range = 'bytes=' + this.getCompleteWorkload() + '-'
    Logger.d(this, 'doStart redirectCount=' + this.redirectCount + ' range=' + range)
    this.taskInfo.header = { 'range': range }
    this.download()
      .then((result) => {
        if (result) {
          this.statusManager.setStatus(TaskStatus.COMPLETE)
        }
      })
      .catch((e) => {
        Logger.e(this, 'doStart download failed! e=' + JSON.stringify(e))
        this.statusManager.onError(JSON.stringify(e))
      })
  }

  async download(): Promise<boolean> {
    Logger.e(this, 'download')
    if (this.redirectCount > 10) {
      this.statusManager.onError('to many redirect!')
      return false
    }

    let httpRequest = http.createHttp()
    Logger.e(this, 'download httpRequest')
    let resp = await httpRequest.request(this.taskInfo.url, {
      method: http.RequestMethod.GET,
      readTimeout: 20000,
      connectTimeout: 20000,
//      header: this.taskInfo.header,
      expectDataType: http.HttpDataType.ARRAY_BUFFER
    })
    Logger.e(this, 'download resp=' + JSON.stringify(resp))

    let code = resp.responseCode
    if (code < 300) {
      if (resp.result instanceof ArrayBuffer) {
        return this.save(resp.result)
      } else {
        this.statusManager.onError('not support data type: ' + resp.resultType)
        return false
      }
    } else if (code < 400) {
      // 重定向
      this.redirectCount++
      let location = resp.header['location']
      if (location && location != '') {
        this.taskInfo.url = location
        return this.download()
      }
    }
  }

  async save(buffer: ArrayBuffer): Promise<boolean> {
    if (this.getStatus() != TaskStatus.PROCESSING) {
      return false
    }
    let file = await fs.open(this.getFilePath(), fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
    return this.saveSlice(file.fd, buffer)
  }

  async saveSlice(fd: number, buffer: ArrayBuffer): Promise<boolean> {
    if (this.getStatus() != TaskStatus.PROCESSING) {
      return false
    }
    Logger.d(this, 'saveSlice  byteLength=' + buffer.byteLength)
    let result = await fs.write(fd, buffer, { encoding: 'utf-8' })
    Logger.e(this, 'saveSlice result=' + result)
    if (this.getStatus() != TaskStatus.PROCESSING) {
      return false
    }
    if (this.observerDispatcher.progressManager) {
      this.observerDispatcher.progressManager.onReceived(result)
    }
    return true
  }
}

export abstract class GroupDownloadTask<T extends DownloadTaskInfo = DownloadTaskInfo> extends FileDownloadTask<T> {
  readonly childTaskManager: TaskManager

  constructor(manager: TaskManager, childTaskManager: TaskManager, taskInfo: T) {
    super(manager, taskInfo)
    this.childTaskManager = childTaskManager
    this.childTaskManager.parentTask = this
    // TODO 开始时加载子任务
    this.childTaskManager.loadTasks()
  }

  doStart() {
    // this.initChildTasks()
    this.childTaskManager.startAll()
  }

  doWaiting() {
    this.childTaskManager.waitingAll()
  }

  doPause() {
    this.childTaskManager.pauseAll()
  }

  // TODO
  //    protected abstract initChildTasks(emitter)

  //    protected abstract initChildTasks()

}

export abstract class ChildDownloadTask<T extends DownloadTaskInfo> extends FileDownloadTask<T> {
  constructor(manager: TaskManager, taskInfo: T) {
    super(manager, taskInfo)
  }

  getFilePath(): string {
    if (this.manager.parentTask instanceof FileDownloadTask) {
      return this.manager.parentTask.getFilePath()
    }
    return super.getFilePath()
  }
}