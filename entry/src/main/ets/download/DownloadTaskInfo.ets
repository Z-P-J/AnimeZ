import TaskInfo from './core/TaskInfo';

export default class DownloadTaskInfo extends TaskInfo {

    fileName: string
    downloadDir: string
    originalUrl: string
    offset: number =  0
    contentLength: number = -1
    url: string
    blockDownload: boolean = false

    constructor(taskId: number, parentTaskId: number, createTime: number = new Date().getTime()) {
        super(taskId, parentTaskId, createTime)
    }

}