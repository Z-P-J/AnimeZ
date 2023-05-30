import BimiAcgDataSource from '../../api/impl/BimiAcgDataSource';
import DownloadTaskRepository from '../../download/DownloadTaskRepository';
import M3u8 from './M3U8';
import M3U8Utils from './M3U8Utils';
import DownloadTaskInfo from '../../download/DownloadTaskInfo';
import { FileDownloadTask, GroupDownloadTask } from '../../download/FileDownloadTask';
import fs from '@ohos.file.fs';
import fio from '@ohos/fileio-extra';
import Logger from '../../utils/Logger';
import TaskManager from '../../download/core/TaskManager';
import { Downloader } from '../../download/Downloader';
import { CryptoJS } from '@ohos/crypto-js'

class M3U8SegmentTaskManager extends TaskManager<FileDownloadTask, FileDownloadTask> {
  constructor(parentTask: FileDownloadTask = null) {
    super(parentTask, new DownloadTaskRepository());
  }

  createTask(taskInfo: DownloadTaskInfo): FileDownloadTask  {
    return new FileDownloadTask(this, taskInfo);
  }

}

class M3U8DownloadTask extends GroupDownloadTask {
  private readonly taskDir
  private m3u8: M3u8 = null

  constructor(manager: TaskManager, taskInfo: DownloadTaskInfo) {
    super(manager, new M3U8SegmentTaskManager(), taskInfo)
    this.taskDir = this.getDownloadDir() + CryptoJS.MD5(taskInfo.originalUrl) + '/'
  }

  doDelete() {
    fs.rmdir(this.taskDir)
  }

  doInit() {
    Logger.e(this, 'doInit taskInfo=' + JSON.stringify(this.taskInfo))
    this.initTask()
      .then((result) => {
        Logger.e(this, 'doInit initM3u8 result=' + result)
        this.taskInfo.prepared = true;
        this.process()
      })
      .catch((e) => {
        Logger.e(this, 'M3U8Utils e=' + JSON.stringify(e))
        this.statusManager.onError(JSON.stringify(e))
      })
  }

  private async initTask(): Promise<number> {
    let source = new BimiAcgDataSource()
    let url = await source.parseVideoUrl(this.taskInfo.originalUrl)
    if (url) {
      return await this.initM3u8()
    }
    throw new Error('init task failed! originalUrl: ' + this.taskInfo.originalUrl)
  }

  private async initM3u8(): Promise<number> {
    if (this.taskInfo.prepared) {
      return 0
    }
    if (!this.m3u8) {
      this.m3u8 = await M3U8Utils.parse(null, this.taskInfo.url)
      Logger.e(this, 'initM3u8 m3u8=' + JSON.stringify(this.m3u8))
      Logger.e(this, 'initM3u8 taskDir=' + this.taskDir + ' exists=' + fio.pathExistsSync(this.taskDir))
      if (!fio.pathExistsSync(this.taskDir)) {
        fio.mkdirsSync(this.taskDir)
      }
      Logger.e(this, 'initM3u8 taskDir exists=' + fio.pathExistsSync(this.taskDir))
      let file = await fs.open(this.taskDir + 'video.info', fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      let result = await fs.write(file.fd, JSON.stringify(this.m3u8), { encoding: 'utf-8' })

      Logger.e(this, 'save m3u8 result=' + result)

    }
    //    let m3u8 = await M3U8Utils.parse(null, this.taskInfo.url)
    Logger.e(this, 'initM3u8 m3u8=' + JSON.stringify(this.m3u8))

    let result = await M3U8Utils.saveM3U8LocalInfo(this.m3u8, this.taskDir + 'index.m3u8')
    Logger.e(this, 'initM3u8 saveM3U8LocalInfo result=' + result)
    result = await M3U8Utils.saveM3U8OriginInfo(this.m3u8, this.taskDir + 'index_origin.m3u8')
    Logger.e(this, 'initM3u8 saveM3U8OriginInfo result=' + result)

    return result
  }

  doStart() {
    Logger.e(this, 'doStart')
    this.prepare()
      .then(() => {
        this.childTaskManager.startAll()
      })
      .catch((e) => {
        this.statusManager.onError(JSON.stringify(e))
      })
  }

  private async prepare() {
    Logger.e(this, 'prepare')
    if (!this.m3u8) {
      let infoPath = this.taskDir + 'video.info'
      Logger.e(this, 'prepare infoPath=' + infoPath)
      let text = await fs.readText(infoPath, { encoding: 'utf-8' })
      Logger.e(this, 'prepare text=' + text)
      this.m3u8 = JSON.parse(text)
    }
    if (this.childTaskManager.tasks.length == 0) {
      let keyUrls = new Set<string>()
      for (let seg of this.m3u8.segmentList) {
        let taskInfo = new DownloadTaskInfo(this.childTaskManager.generateTaskId(), this.childTaskManager.getParentTaskId())
        taskInfo.taskName = seg.name
        taskInfo.fileName = seg.name
        taskInfo.originalUrl = seg.url
        taskInfo.url = seg.url
        taskInfo.downloadDir = this.taskDir
        Logger.e(this, "init segment task : " + JSON.stringify(taskInfo))
        this.childTaskManager.addTask(new FileDownloadTask(this.childTaskManager, taskInfo))

        // 下载key密钥文件
        if (seg.hasKey && seg.keyUrl) {
          if (keyUrls.has(seg.keyUrl)) {
            continue
          }
          keyUrls.add(seg.keyUrl)
          let taskInfo = new DownloadTaskInfo(this.childTaskManager.generateTaskId(), this.childTaskManager.getParentTaskId())
          taskInfo.originalUrl = seg.keyUrl
          taskInfo.url = seg.keyUrl
          taskInfo.fileName = seg.keyName
          taskInfo.taskName = seg.keyName
          taskInfo.downloadDir = this.taskDir
          this.childTaskManager.addTask(new FileDownloadTask(this.childTaskManager, taskInfo))
        }
      }
    }
  }
}

export default class M3U8Downloader extends Downloader<M3U8DownloadTask> {

//  with(url: string): DownloadTaskBuilder<M3U8DownloadTask> {
//    return new DownloadTaskBuilder<M3U8DownloadTask>(this, url)
//  }

  createTask(taskInfo: DownloadTaskInfo): M3U8DownloadTask  {
    return new M3U8DownloadTask(this, taskInfo);
  }
}

//export class M3U8DownloadTaskBuilder extends DownloadTaskBuilder<M3U8DownloadTask> {
//  constructor(taskManager: TaskManager<Task, M3U8DownloadTask>, url: string) {
//    super(taskManager, url)
//  }
//
//  build(): M3U8DownloadTask {
//    let taskInfo = new DownloadTaskInfo(this.taskManager.generateTaskId(), this.taskManager.getParentTaskId())
//    taskInfo.url = this.url
//    taskInfo.fileName = this.taskName
//    taskInfo.downloadDir = this.downloadDir + CryptoJS.MD5(this.url)
//    let downloadTask = this.taskManager.createTask(taskInfo);
//    this.taskManager.addTask(downloadTask)
//    return downloadTask;
//  }
//}