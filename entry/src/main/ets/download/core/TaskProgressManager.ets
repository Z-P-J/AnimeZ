import TaskInfo from './TaskInfo';
import Task from './Task'
import Logger from '../../utils/Logger';


export default class TaskProgressManager {
    private readonly task: Task;
    //    totalSize = 0;
    //    receivedSize = 0;
    //    downloadProgress = 0;
    private readonly progressDuration;
    private readonly maxProgress;
    private progressHandler: Function = null;

    private readonly tag: string;

    private lastTime: number = 0

    constructor(task: Task, maxProgress: number = 100, progressDuration: number = 1000) {
        this.task = task;
        this.tag = task.constructor.name + ".ProgressManager"
        this.progressDuration = progressDuration
        this.maxProgress = maxProgress
    }

    init(task: Task) {
        // TODO
    }

    onInitSize(size: number) {
        this.task.taskInfo.totalSize += size;
        let parentTask = this.task.getParentTask();
        if (parentTask) {
            parentTask.observerDispatcher.progressManager.onInitSize(size);
        }
    }

    onReceived(size: number) {
        this.task.taskInfo.receivedSize += size;
        Logger.d(this.tag, 'onReceived size=' + size + ' receivedSize=' + this.task.taskInfo.receivedSize);
        if (this.task.taskInfo.totalSize > 0) {
            this.task.taskInfo.downloadProgress = this.task.getReceivedSize() / this.task.getTotalSize() * this.maxProgress;
        }
        let currentTime = new Date().getTime()
        if (this.lastTime - currentTime > 500) {
            this.task.manager.onProgressChanged(this.task)
            this.lastTime = currentTime
        }
        let parentTask = this.task.getParentTask();
        if (parentTask) {
            parentTask.observerDispatcher.progressManager.onReceived(size);
        }
    }

    loopForProgress() {
        if (this.progressHandler) {
            return;
        }
        if (this.canLoopForProgress()) {
            this.progressHandler = () => {
                if (this.canLoopForProgress()) {
                    this.task.observerDispatcher.notifyProgress();
                    setTimeout(this.progressHandler, this.progressDuration);
                } else {
                    this.progressHandler = null;
                }
            }
            setTimeout(this.progressHandler, this.progressDuration);
        }
    }

    stop() {
        // TODO

    }

    protected canLoopForProgress() {
        if (this.task.observerDispatcher.observers) {
            return this.task.isRunning();
        }
        return false;
    }
}