import { Downloader } from './Downloader';
import DownloadTaskInfo from './DownloadTaskInfo';
import Task from './core/Task';
import TaskManager from './core/TaskManager';
import { FileDownloadTask } from './FileDownloadTask';
import TaskBuilder from './core/TaskBuilder';

/**
 * 下载任务构造者
 */
export default class DownloadTaskBuilder<T extends FileDownloadTask> implements TaskBuilder<T> {
    readonly taskManager: Downloader<T>
    taskName: string;
    url: string;
    fileName: string
    downloadDir: string;

    constructor(taskManager: Downloader<T>, url: string) {
        this.taskManager = taskManager
        this.url = url
    }

    setUrl(url: string) {
        this.url = url
        return this
    }

    setTaskName(name: string) {
        this.taskName = name
        return this
    }

    setFileName(name: string) {
        this.fileName = name
        return this
    }

    setDownloadDir(dir: string) {
        this.downloadDir = dir
        return this
    }

    build(): T {
        return this.taskManager.buildTask(this)
//        let taskInfo = new DownloadTaskInfo(this.taskManager.generateTaskId(), this.taskManager.getParentTaskId())
//        taskInfo.taskName = this.taskName
//        taskInfo.originalUrl = this.url
//        taskInfo.url = this.url
//        taskInfo.fileName = this.fileName
//        taskInfo.downloadDir = this.downloadDir
//        let downloadTask = this.taskManager.createTask(taskInfo);
//        this.taskManager.addTask(downloadTask)
//        return downloadTask;
    }

    //    start() {
    //        this.build().start();
    //    }


}