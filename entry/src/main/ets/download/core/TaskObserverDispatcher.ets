import TaskInfo from './TaskInfo';
import Task from './Task';
import TaskProgressManager from './TaskProgressManager';
import TaskObserver from './TaskObserver';


export default class TaskObserverDispatcher {
    private readonly task: Task<TaskInfo>;

    observers: TaskObserver[] = null;

    readonly progressManager: TaskProgressManager = null;

    constructor(task: Task<TaskInfo>) {
        this.task = task;
        this.progressManager = new TaskProgressManager(task)
    }

    init(task: Task<TaskInfo>) {
        // TODO
    }

    addObserver(observer: TaskObserver) {
        if (!this.observers) {
            this.observers = [];
//            this.progressManager = new ProgressManager(this.task)
        }
        this.observers.push(observer);
    }

    removeObserver(observer: TaskObserver): boolean {
        if (this.observers) {
            let index = this.observers.indexOf(observer);
            if (index >= 0) {
                this.observers.splice(index, 1);
                if (this.observers.length == 0) {
                    this.observers = null;
                    this.stopProgress()
//                    this.progressManager = null
                }
                return true;
            }
        }
        return false;
    }

    notifyStart() {
        if (this.task && this.observers) {
//            if (!this.progressManager) {
//                this.progressManager = new ProgressManager(this.task)
//            }
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

    notifyFinished() {
        if (this.task && this.observers) {
            this.stopProgress()
            this.observers.forEach((o) => {
                o.onFinished();
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
                totalSize = this.task.getTotalSize()
            }
            if (receivedSize == undefined) {
                receivedSize = this.task.getReceivedSize()
            }
            if (progress == undefined) {
                progress = this.task.getProgress()
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