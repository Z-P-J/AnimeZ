import Logger from '../../utils/Logger';
import TaskInfo from './TaskInfo';
import Task from './Task';
import TaskProgressManager from './TaskProgressManager';
import TaskObserver from './TaskObserver';


export default class TaskObserverDispatcher {
    private readonly task: Task<TaskInfo>;

    observers: TaskObserver[] = null;

    readonly progressManager: TaskProgressManager = null;
    private readonly tag: string;

    constructor(task: Task<TaskInfo>) {
        this.tag = task.constructor.name + '.TaskObserverDispatcher';
        this.task = task;
        this.progressManager = new TaskProgressManager(task)
    }

    init(task: Task<TaskInfo>) {
        // TODO
    }

    addObserver(observer: TaskObserver) {
        if (!this.observers) {
            this.observers = [];
        }
        this.observers.push(observer);
    }

    removeObserver(observer: TaskObserver): boolean {
        if (this.observers) {
            let index = this.observers.indexOf(observer)
            Logger.e(this.tag, 'removeObserver index=' + index + ' len=' + this.observers.length)
            if (index >= 0) {
                let result = this.observers.splice(index, 1)
                Logger.e(this.tag, 'removeObserver this.observers.len=' + this.observers.length + ' result=' + result)
                if (this.observers.length == 0) {
                    this.observers = null;
                    this.stopProgress()
                }
                return true;
            }
        }
        return false;
    }

    notifyStart() {
        if (this.task && this.observers) {
            this.progressManager.loopForProgress()
            this.observers.forEach((o) => {
                o.onStart();
            });
        }
    }

    notifyPreparing() {
        if (this.task && this.observers) {
            this.stopProgress()
            this.observers.forEach((o) => {
                o.onPreparing();
            });
        }
    }

    notifyPaused() {
        if (this.task && this.observers) {
            this.stopProgress()
            this.observers.forEach((o) => {
                o.onPaused();
            });
        }
    }

    notifyWaiting() {
        if (this.task && this.observers) {
            this.stopProgress()
            this.observers.forEach((o) => {
                o.onWaiting();
            });
        }
    }

    notifyComplete() {
        if (this.task && this.observers) {
            this.stopProgress()
            this.observers.forEach((o) => {
                o.onComplete();
            });
        }
    }

//    notifyProgress() {
//        if (this.observers) {
//            let totalSize = this.task.getTotalSize();
//            let receivedSize = this.task.getReceivedSize();
//            let progress = this.task.getProgress();
//            this.observers.forEach((o) => {
//                o.onProgress(totalSize, receivedSize, progress);
//            });
//        }
//    }

    notifyProgress(totalSize?: number, receivedSize?: number, progress?: number) {
        if (this.task && this.observers) {
            if (totalSize == undefined) {
                totalSize = this.task.getTotalWorkload()
            }
            if (receivedSize == undefined) {
                receivedSize = this.task.getCompleteWorkload()
            }
            if (progress == undefined) {
                progress = this.task.getTaskProgress()
            }
            this.observers.forEach((o) => {
                o.onProgress(totalSize, receivedSize, progress);
            });
        }
    }

    notifyError(message?: string) {
        if (this.task && this.observers) {
            this.stopProgress()
            if (message == undefined) {
                message = this.task.getMessage()
            }
            this.observers.forEach((o) => {
                o.onError(message);
            });
        }
    }

    private stopProgress() {
        if (this.progressManager) {
            this.progressManager.stop()
        }
    }

}