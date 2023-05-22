//import M3U8Utils from './M3U8Utils';
//import fs from '@ohos.file.fs';
//import request from '@ohos.request';
//import Logger from '../../utils/Logger';
//import { CryptoJS } from '@ohos/crypto-js'
//
//class DownTask {
//  private readonly url: string
//  private readonly path: string
//
//  private readonly tasks: request.DownloadTask[] = []
//
//  constructor(url) {
//    this.url = url
//    this.path = getContext(this).filesDir + /download/ + CryptoJS.MD5(url)
//  }
//
//  start() {
//
//  }
//
//  private async downloadM3u8(): Promise<request.DownloadTask> {
//    let task = await request.downloadFile(getContext(this), {
//      url: this.url,
//      filePath: this.path
//    });
//    let info = await task.getTaskInfo()
//    if (info.status == request.SESSION_SUCCESSFUL && fs.accessSync(this.path)) {
//      return null
//    } else {
//      task.on("progress", (receivedSize: number, totalSize: number) => {
//        Logger.e(this, 'down progress rec=' + receivedSize + " total=" + totalSize)
//      })
//      task.on("complete", () => {
//        this.download()
//      })
//      task.on("pause", () => {
//        this.statusManager.setStatus(TaskStatus.PAUSED)
//      })
//      task.on("fail", (err) => {
//        this.statusManager.onError("err: " + err)
//      })
//      task.restore()
//    }
//    return task
//  }
//
//  private async downloadSegments() {
//
//  }
//
//}
//
//export default class M3U8Down {
//  download(url: string) {
//
//  }
//
//  private async down(url, path) {
//    Logger.e(this, 'down')
//    let task = await request.downloadFile(getContext(this), {
//      url: url,
//      filePath: path
//    });
//    let info = await task.getTaskInfo()
//    Logger.e(this, 'down info=' + JSON.stringify(info))
//    if (info.status == request.SESSION_SUCCESSFUL) {
//      this.download()
//    } else {
//      task.on("progress", (receivedSize: number, totalSize: number) => {
//        Logger.e(this, 'down progress rec=' + receivedSize + " total=" + totalSize)
//      })
//      task.on("complete", () => {
//        this.download()
//      })
//      task.on("pause", () => {
//        this.statusManager.setStatus(TaskStatus.PAUSED)
//      })
//      task.on("fail", (err) => {
//        this.statusManager.onError("err: " + err)
//      })
//      task.restore()
//    }
//  }
//
//  private downloadSegments(url, path) {
//    let content = fs.readTextSync(path)
//    Logger.e(this, 'initChildTasks content=' + content)
//
//    M3U8Utils.parse(null, url, content)
//      .then((m3u8) => {
//        for (let seg of m3u8.segmentList) {
//          let taskInfo = new DownloadTaskInfo()
//          taskInfo.id = 0
//          taskInfo.originalUrl = seg.url
//          taskInfo.url = seg.url
//          taskInfo.fileName = seg.name
//          taskInfo.downloadDir = this.taskInfo.downloadDir
//          Logger.e(this, "init segment task : " + JSON.stringify(taskInfo))
//          this.childTaskManager.addTask(new M3U8SegmentTask(this.childTaskManager, taskInfo))
//        }
//        this.childTaskManager.startAll()
//      })
//      .catch((e) => {
//        Logger.e(this, 'downloadSegments failed! e=' + JSON.stringify(e))
//      })
//  }
//}