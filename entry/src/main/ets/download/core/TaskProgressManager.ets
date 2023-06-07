import Task from './Task'
import Logger from '../../utils/Logger'

/**
 * 任务进度管理
 */
export default class TaskProgressManager {

    /**
     * 当前任务
     */
    private readonly task: Task

    /**
     * 任务进度更新频率
     */
    private readonly progressDuration

    /**
     * 最大任务进度
     */
    private readonly maxProgress

    private progressHandler: Function = null

    private readonly tag: string

    private lastTime: number = 0

    constructor(task: Task, maxProgress: number = 100, progressDuration: number = 1000) {
        this.task = task
        this.tag = task.constructor.name + ".ProgressManager"
        this.progressDuration = progressDuration
        this.maxProgress = maxProgress
        
        if (task.getTotalWorkload() > 0) {
            task.taskInfo.taskProgress = task.getCompleteWorkload() / task.getTotalWorkload() * this.maxProgress
        }
    }

    init(task: Task) {
        // TODO
    }

    /**
     * 初始化任务量
     * @param size
     */
    onInitSize(size: number) {
        this.task.taskInfo.totalWorkload += size
        let parentTask = this.task.getParentTask()
        if (parentTask) {
            parentTask.observerDispatcher.progressManager.onInitSize(size)
        }
    }

    private progressTimer: number = -1;

    /**
     * 当完成一定的任务量
     * @param size
     */
    onReceived(size: number) {
        this.task.taskInfo.completeWorkload += size
        Logger.d(this.tag, 'onReceived size=' + size + ' receivedSize=' + this.task.taskInfo.completeWorkload)
        if (this.task.taskInfo.totalWorkload > 0) {
            this.task.taskInfo.taskProgress = this.task.getCompleteWorkload() / this.task.getTotalWorkload() * this.maxProgress
        }
        let currentTime = new Date().getTime()
        if (this.lastTime - currentTime >= this.progressDuration) {
            this.lastTime = currentTime
            this.task.manager.onProgressChanged(this.task)
            this.task.observerDispatcher.notifyProgress()
            if (this.progressTimer >= 0) {
                clearTimeout(this.progressTimer)
            }
            this.notifyProgressChangedDelay()
        } else {
            if (this.progressTimer < 0) {
                this.lastTime = currentTime
                this.task.manager.onProgressChanged(this.task)
                this.task.observerDispatcher.notifyProgress()
                this.notifyProgressChangedDelay()
            }
        }

//        if (this.lastTime - currentTime >= 500) {
//            this.task.manager.onProgressChanged(this.task)
//            this.lastTime = currentTime
//        }
        let parentTask = this.task.getParentTask()
        if (parentTask) {
            parentTask.observerDispatcher.progressManager.onReceived(size)
        }
    }

    private notifyProgressChangedDelay() {
        this.progressTimer = setTimeout(() => {
            this.progressTimer = -1
            this.task.manager.onProgressChanged(this.task)
            this.task.observerDispatcher.notifyProgress()
        }, this.progressDuration)
    }

    /**
     * 循环更新任务进度
     */
    loopForProgress() {
//        if (this.progressHandler) {
//            return
//        }
//        if (this.canLoopForProgress()) {
//            this.progressHandler = () => {
//                if (this.canLoopForProgress()) {
//                    this.task.observerDispatcher.notifyProgress()
//                    setTimeout(this.progressHandler, this.progressDuration)
//                } else {
//                    this.progressHandler = null
//                }
//            }
//            setTimeout(this.progressHandler, this.progressDuration)
//        }
    }

    stop() {
        // TODO

    }

    /**
     * 是否支持更新任务进度
     */
    protected canLoopForProgress() {
        if (this.task.observerDispatcher.observers) {
            return this.task.isProcessing()
        }
        return false
    }
}