import DownloadTaskInfo from './DownloadTaskInfo';
import Task from './core/Task';
import DownloadTaskInfoRepository from './DownloadTaskInfoRepository';
import { FileDownloadTask } from './FileDownloadTask';
import TaskInfo from './core/TaskInfo';
import TaskInfoRepository from './core/TaskInfoRepository';
import TaskManager from './core/TaskManager';
import DownloadTaskBuilder from './DownloadTaskBuilder';

/**
 * 下载器抽象类，Downloader本质上是对下载任务的管理，所以继承自TaskManager
 * Downloader和TaskManager的区别是Downloader支持创建下载任务
 */
export abstract class Downloader<T extends FileDownloadTask = FileDownloadTask> extends TaskManager<Task, T> {
    constructor(taskInfoRepository: TaskInfoRepository<TaskInfo> = new DownloadTaskInfoRepository()) {
        super(null, taskInfoRepository);
    }

    /**
     * 创建下载任务Builder
     * @param url
     */
    with(url: string): DownloadTaskBuilder<T> {
        return new DownloadTaskBuilder<T>(this, url)
    }

    /**
     * 创建下载任务
     * @param builder
     */
    buildTask(builder: DownloadTaskBuilder<T>): T {
        let taskInfo = new DownloadTaskInfo(this.generateTaskId(), this.getParentTaskId())
        taskInfo.taskName = builder.taskName
        taskInfo.originalUrl = builder.url
        taskInfo.url = builder.url
        taskInfo.fileName = builder.fileName
        taskInfo.downloadDir = builder.downloadDir
        let downloadTask = this.createTask(taskInfo);
        this.addTask(downloadTask)
        return downloadTask;
    }

}