import TaskInfo from './core/TaskInfo';

/**
 * 下载任务信息
 */
export default class DownloadTaskInfo extends TaskInfo {

    /**
     * 文件名
     * TODO 已经有taskName了，fileName是否有存在的意义？
     */
    fileName: string

    /**
     * 文件下载目录
     */
    downloadDir: string

    /**
     * 原始下载链接
     */
    originalUrl: string

    /**
     * 最新的下载链接，可能和originalUrl相同，也可能是originalUrl重定向的链接
     */
    url: string

    /**
     * 下载内容偏移量，主要用于分片下载，默认为0无偏移量
     */
    offset: number =  0

    /**
     * 文件内容大小
     */
    contentLength: number = -1

    /**
     * 是否支持分片下载
     */
    blockDownload: boolean = false

    /**
     * 缓冲大小
     */
    bufferSize: number = 512 * 1024

//    totalSize: number = 0
//
//    receivedSize: number = 0

    constructor(taskId: number, parentTaskId: number, createTime: number = new Date().getTime()) {
        super(taskId, parentTaskId, createTime)
    }

}