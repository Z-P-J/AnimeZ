import M3U8VideoInfo from './M3U8VideoInfo';
import DownloadTaskBuilder from '../../download/DownloadTaskBuilder';
import BimiAcgDataSource from '../../api/impl/BimiAcgDataSource';
import DownloadTaskInfoRepository from '../../download/DownloadTaskInfoRepository';
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

class M3U8DownloadTaskBuilder extends DownloadTaskBuilder<M3U8DownloadTask> {

  pageLink: string
  coverUrl: string

  setPageLink(pageLink: string) {
    this.pageLink = pageLink
    return this;
  }

  setCoverUrl(coverUrl: string) {
    this.coverUrl = coverUrl
    return this;
  }


}

/**
 * m3u8下载器
 */
export default class M3U8Downloader extends Downloader<M3U8DownloadTask> {

  with(url: string): M3U8DownloadTaskBuilder {
    return new M3U8DownloadTaskBuilder(this, url)
  }

  /**
   * 创建下载任务
   */
  createTask(taskInfo: DownloadTaskInfo): M3U8DownloadTask  {
    return new M3U8DownloadTask(this, taskInfo);
  }

  buildTask(builder: M3U8DownloadTaskBuilder): M3U8DownloadTask {
    let downloadTask = super.buildTask(builder)
    downloadTask.videoInfo.pageLink = builder.pageLink
    downloadTask.videoInfo.coverUrl = builder.coverUrl
    return downloadTask
  }
}

/**
 * m3u8下载任务
 */
export class M3U8DownloadTask extends GroupDownloadTask {
  private readonly taskDir
  readonly videoInfo: M3U8VideoInfo = new M3U8VideoInfo()

  constructor(manager: TaskManager, taskInfo: DownloadTaskInfo) {
    super(manager, new M3U8SegmentTaskManager(), taskInfo)
    this.taskDir = this.getDownloadDir() + CryptoJS.MD5(taskInfo.originalUrl) + '/'
  }

  doDelete() {
    fs.rmdir(this.taskDir)
  }

  getLocalM3U8Path(): string {
    return this.taskDir + 'index.m3u8'
  }

  /**
   * 从本地恢复下载任务
   */
  async doRestore(): Promise<void> {
    Logger.e(this, 'doRestore')
    let infoPath = this.taskDir + 'video.info'
    Logger.e(this, 'doRestore infoPath=' + infoPath)
    let text = await fs.readText(infoPath, { encoding: 'utf-8' })
    Logger.e(this, 'doRestore text=' + text)
    let info = JSON.parse(text);
    this.videoInfo.pageLink = info.pageLink
    this.videoInfo.coverUrl = info.coverUrl
    this.videoInfo.m3u8 = info.m3u8
    Logger.e(this, 'doRestore videoInfo=' + JSON.stringify(this.videoInfo))
  }

  /**
   * 初始化
   */
  doInit() {
    Logger.e(this, 'doInit taskInfo=' + JSON.stringify(this.taskInfo))
    this.initTask()
      .then((result) => {
        Logger.e(this, 'doInit initM3u8 result=' + result)
        // 初始化完成
        this.taskInfo.prepared = true;
        // 继续下载任务
        this.process()
      })
      .catch((e) => {
        Logger.e(this, 'M3U8Utils e=' + JSON.stringify(e))
        this.statusManager.onError(JSON.stringify(e))
      })
  }

  /**
   * 初始化任务
   */
  private async initTask(): Promise<number> {
    let source = new BimiAcgDataSource()
    // 解析真实的m3u8链接
    this.taskInfo.url = await source.parseVideoUrl(this.taskInfo.originalUrl)
    Logger.e(this, 'initTask url=' + this.taskInfo.url)
    if (this.taskInfo.url) {
      // 初始化m3u8信息
      return await this.initM3u8()
    }
    throw new Error('init task failed! originalUrl: ' + this.taskInfo.originalUrl)
  }

  /**
   * 初始化并保存m3u8信息到本地
   */
  private async initM3u8(): Promise<number> {
    if (this.taskInfo.prepared) {
      return 0
    }
    // m3u8解析
    this.videoInfo.m3u8 = await M3U8Utils.parse(null, this.taskInfo.url)
    Logger.e(this, 'initM3u8 videoInfo=' + JSON.stringify(this.videoInfo))

    if (!this.videoInfo.m3u8 || this.videoInfo.m3u8.segmentList.length == 0) {
      throw new Error('m3u8 parse failed!')
    }

    Logger.e(this, 'initM3u8 taskDir=' + this.taskDir + ' exists=' + fio.pathExistsSync(this.taskDir))
    if (!fio.pathExistsSync(this.taskDir)) {
      fio.mkdirsSync(this.taskDir)
    }
    Logger.e(this, 'initM3u8 taskDir exists=' + fio.pathExistsSync(this.taskDir))
    let file = await fs.open(this.taskDir + 'video.info', fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    // 保存m3u8信息
    // TODO
    let result = await fs.write(file.fd, JSON.stringify(this.videoInfo), { encoding: 'utf-8' })

    Logger.e(this, 'save m3u8 result=' + result)

    // 将m3u8信息转换为本地m3u8，并保存至本地
    result = await M3U8Utils.saveM3U8LocalInfo(this.videoInfo.m3u8, this.getLocalM3U8Path())
    Logger.e(this, 'initM3u8 saveM3U8LocalInfo result=' + result)
    // 将m3u8原始信息保存至本地
    result = await M3U8Utils.saveM3U8OriginInfo(this.videoInfo.m3u8, this.taskDir + 'index_origin.m3u8')
    Logger.e(this, 'initM3u8 saveM3U8OriginInfo result=' + result)

    return result
  }

  /**
   * 开始下载
   */
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

  /**
   * 准备分片下载任务
   */
  private async prepare() {
    Logger.e(this, 'prepare')
    if (!this.videoInfo.m3u8) {
      let infoPath = this.taskDir + 'video.info'
      Logger.e(this, 'prepare infoPath=' + infoPath)
      let text = await fs.readText(infoPath, { encoding: 'utf-8' })
      Logger.e(this, 'prepare text=' + text)
      this.videoInfo.m3u8 = JSON.parse(text)
    }
    if (this.childTaskManager.tasks.length == 0) {
      let keyUrls = new Set<string>()
      for (let seg of this.videoInfo.m3u8.segmentList) {
        let taskInfo = new DownloadTaskInfo(this.childTaskManager.generateTaskId(), this.childTaskManager.getParentTaskId())
        taskInfo.taskName = seg.name
        taskInfo.fileName = seg.name
        taskInfo.originalUrl = seg.url
        taskInfo.url = seg.url
        taskInfo.downloadDir = this.taskDir
        Logger.e(this, "init segment task : " + JSON.stringify(taskInfo))
        // 添加分片下载子任务
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
          // 添加密钥下载子任务
          this.childTaskManager.addTask(new FileDownloadTask(this.childTaskManager, taskInfo))
        }
      }
    }
  }
}

/**
 * m3u8分片下载任务管理
 */
class M3U8SegmentTaskManager extends TaskManager<FileDownloadTask, FileDownloadTask> {
  constructor(parentTask: FileDownloadTask = null) {
    super(parentTask, new DownloadTaskInfoRepository());
  }

  /**
   * 创建m3u8分片下载任务
   */
  createTask(taskInfo: DownloadTaskInfo): FileDownloadTask  {
    return new FileDownloadTask(this, taskInfo);
  }

}

