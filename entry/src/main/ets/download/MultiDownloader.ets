import Task from './core/Task';
import { TaskStatus } from './core/Task';
import DownloadTaskInfoRepository from './DownloadTaskInfoRepository';
import DownloadTaskBuilder from './DownloadTaskBuilder';
import DownloadTaskInfo from './DownloadTaskInfo';
import { FileDownloadTask, GroupDownloadTask } from './FileDownloadTask';
import fs from '@ohos.file.fs';
import http from '@ohos.net.http';
import Logger from '../utils/Logger';
import TaskManager from './core/TaskManager';
import { Downloader } from './Downloader';

class DownloadTaskManager extends TaskManager {
    constructor(parentTask: FileDownloadTask = null) {
        super(parentTask, new DownloadTaskInfoRepository());
    }

    createTask(taskInfo: DownloadTaskInfo): BlockTask  {
        return new BlockTask(this, taskInfo);
    }

}

/**
 * 支持分片下载的下载任务
 */
class MultiDownloadTask extends GroupDownloadTask<DownloadTaskInfo> {

    constructor(manager: TaskManager, taskInfo: DownloadTaskInfo) {
        super(manager, new DownloadTaskManager(), taskInfo);
    }

    doStart() {
        this.initChildTasks()
        this.childTaskManager.startAll()
    }

    protected initChildTasks() {
        if (this.childTaskManager.tasks.length != 0) {
            return;
        }

        let totalSize = this.getTotalWorkload();
        if (this.taskInfo.blockDownload) {
            // 分块下载，断点续传
            if (totalSize < 1024 * 1024) {
                this.createBlockTask(0, -1);
            } else {
                let maxBlockSize = 4 * 1024 * 1024;
                if (totalSize < 3 * maxBlockSize) {
                    let blockCount = 3;
                    let blockSize = Math.floor(Math.floor(totalSize / 1024) * 1024 / blockCount);
                    for (let i = 0; i < blockCount - 1; i++) {
                        this.createBlockTask(i * blockSize, i * blockSize + blockSize);
                    }
                    this.createBlockTask((blockCount - 1) * blockSize, totalSize);
                } else {
                    let blockCount = Math.floor(totalSize / maxBlockSize);
                    let blockSize = maxBlockSize;
                    for (let i = 0; i < blockCount; i++) {
                        this.createBlockTask(i * blockSize, i * blockSize + blockSize);
                    }
                    if (totalSize >= blockCount * blockSize) {
                        this.createBlockTask(blockCount * blockSize, totalSize);
                    }
                }
            }
        } else {
            // 不支持分块下载
            this.createBlockTask(0, -1);
        }
    }

    createBlockTask(begin: number, end: number) {
        let taskInfo = new DownloadTaskInfo(this.childTaskManager.generateTaskId(), this.childTaskManager.getParentTaskId())

        taskInfo.offset = begin
        taskInfo.contentLength = end - begin

//        let range
//        if (end <= 0) {
//            range = 'bytes=0-'
//        } else {
//            range = 'bytes=' + begin + '-' + end
//        }
//        taskInfo.header = {'range': range}
        let blockTask = this.childTaskManager.createTask(taskInfo)
        this.childTaskManager.addTask(blockTask);
    }

}

/**
 * 分块下载子任务
 */
class BlockTask extends FileDownloadTask {
//    private bufferSize = 128 * 1024;

    begin: number;
    end: number;

    constructor(manager: TaskManager, taskInfo: DownloadTaskInfo) {
        super(manager, taskInfo);
//        this.begin = begin;
//        this.end = end;
        // TODO
//        this.taskInfo.header = {}
        this.begin = taskInfo.offset
        this.end = this.begin + taskInfo.contentLength
    }

    doInit() {
        Logger.w(this, 'doInit');
        this.statusManager.setStatus(TaskStatus.PREPARING);
        this.observerDispatcher.progressManager.onInitSize(this.end - this.begin)
        this.taskInfo.prepared = true;
        this.process();
    }

    doStart() {
        Logger.d(this, 'doStart redirectCount=' + this.redirectCount);
        if (this.redirectCount > 10) {
            this.statusManager.onError('to many redirect!')
            return
        }

        let range = 'bytes=' + (this.begin + this.getCompleteWorkload()) + '-';
        if (this.end > 0) {
            range = range + this.end;
        }
        Logger.d(this, 'doStart range=' + range + " url=" + this.taskInfo.url);

        let httpRequest = http.createHttp();
        httpRequest.request(this.taskInfo.url, {
            method: http.RequestMethod.GET,
            readTimeout: 100000,
            connectTimeout: 100000,
            header: {'range': range},
            expectDataType: http.HttpDataType.ARRAY_BUFFER
        }, (err, data) => {
            Logger.w(this, 'doStart data=' + JSON.stringify(data));
            if (data) {
                let code = data.responseCode;
                if (code < 300) {
                    if (data.result instanceof ArrayBuffer) {
                        this.save(data.result);
                    } else {
                        this.statusManager.onError('not support data type: ' + data.resultType);
                    }
                    return;
                } else if (code < 400) {
                    // 重定向
                    httpRequest.destroy();
                    this.redirectCount++;
                    let location = data.header['location'];
                    if (location && location != '') {
                        this.taskInfo.url = location;
                        this.doStart();
                        return;
                    }
                }
                // 请求出错了
                httpRequest.destroy();
                this.statusManager.onError('request error! response code is ' + code);
            } else {
                Logger.w(BlockTask.name, 'doStart err=' + JSON.stringify(err));
                this.statusManager.onError(err.message);
            }
        })
    }

    saveInner(buffer: ArrayBuffer) {
        if (this.getStatus() != TaskStatus.PROCESSING) {
            return;
        }
        fs.open(this.getFilePath(), fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY, (err, file) => {
            if (err) {
                this.statusManager.onError(err.message);
            } else {
                this.saveSliceInner(file.fd, buffer, 0);
            }
        });
    }

    private saveSliceInner(fd: number, buffer: ArrayBuffer, offset: number) {
        if (this.getStatus() != TaskStatus.PROCESSING) {
            return;
        }
        let end = Math.min(offset + this.taskInfo.bufferSize, buffer.byteLength);
        let sliceBuffer = buffer.slice(offset, end);
        Logger.d(this, 'saveSlice offset=' + offset + ' end=' + end + " byteLength=" + buffer.byteLength);
        fs.write(fd, sliceBuffer,
            {
                offset: this.begin + this.getCompleteWorkload(),
                length: sliceBuffer.byteLength,
                encoding: 'utf-8'
            },
            (err, result) => {
                if (this.getStatus() != TaskStatus.PROCESSING) {
                    return;
                }
                if (err) {
                    this.statusManager.onError(err.message);
                } else {
                    this.observerDispatcher.progressManager.onReceived(result);
                    if (end === buffer.byteLength) {
                        this.statusManager.setStatus(TaskStatus.COMPLETE);
                    } else {
                        this.saveSliceInner(fd, buffer, end);
                    }
                }
            })
    }
}

/**
 * 支持分块下载的下载器
 */
export default class MultiDownloader extends Downloader {

    createTask(taskInfo: DownloadTaskInfo): FileDownloadTask  {
        return new MultiDownloadTask(this, taskInfo);
    }

}