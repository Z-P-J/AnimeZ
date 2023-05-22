import { TaskStatus } from './TaskManager';


export default class TaskInfo {
    readonly taskId: number;
    readonly parentTaskId: number
    // TODO
    taskName: string
    status: number = TaskStatus.CREATED
    //    fileName: string;
    //    downloadDir: string;
    //
    //    url: string;

    totalSize = 0;
    receivedSize = 0;
    downloadProgress = 0;

    createTime = 0

//    accessTime = 0

    finishedTime = 0

    //    blockDownload: boolean = false;

    prepared: boolean = false;

    message: string = null;

    header: Object = null

    bufferSize: number = 512 * 1024

    constructor(taskId: number, parentTaskId: number, createTime: number = new Date().getTime()) {
        this.taskId = taskId
        this.parentTaskId = parentTaskId
        this.createTime = createTime
    }
}