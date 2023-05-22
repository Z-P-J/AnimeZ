import TaskInfo from './TaskInfo';
import Task from './Task';
import Logger from '../../utils/Logger';
import { TaskStatusObserver } from './TaskManager';
import { TaskStatus } from './TaskManager';

export default class TaskStatusManager {
    private readonly task: Task;
    private status: TaskStatus = TaskStatus.CREATED;
    // 运行态标志。例如RUNNING状态下statusFlag不为null，
    // 当此时程序崩溃，重新打开应用时，任务状态仍是RUNNING，但是由于object为null，由此判断并非处于RUNNING状态
    private statusFlag: object = null;

    private observers: TaskStatusObserver[];

    private readonly tag: string;

    constructor(task: Task) {
        this.tag = task.constructor.name;
//        this.tag = task.taskInfo.id + " "
//        if (task instanceof Object) {
//            this.tag = task.constructor.name;
//        } else {
//            this.tag = '' + task.taskInfo.
//        }
//        this.tag = task.constructor.name;
        this.task = task;
    }

    getMessage() {
        return this.task.taskInfo.message;
    }

    getStatus(): TaskStatus {
        if (this.status == TaskStatus.PREPARING || this.status == TaskStatus.RUNNING || this.status == TaskStatus.WAITING) {
            if (!this.statusFlag) {
                if (this.getMessage()) {
                    this.status = TaskStatus.ERROR;
                } else {
                    this.status = TaskStatus.PAUSED;
                }
            }
        }
        return this.status;
    }

    setStatus(status: TaskStatus, message?: string) {
        let oldStatus = this.status;
        this.status = status;
        this.task.taskInfo.message = message;
        if (status == TaskStatus.PREPARING || status == TaskStatus.RUNNING || status == TaskStatus.WAITING) {
            if (!this.statusFlag) {
                this.statusFlag = new Object();
            }
        } else if (this.statusFlag) {
            this.statusFlag = null;
        }
        Logger.d(this.tag, 'setStatus oldStatus=' + oldStatus + ' status=' + status + ' observers=' + this.observers);
        if (oldStatus != status) {
            this.task.taskInfo.status = status
            this.onStatusChanged(status)
            if (this.observers) {
                this.observers.forEach((o) => {
                    Logger.w(this.tag, 'setStatus onStatusChanged oldStatus=' + oldStatus + " status=" + status);
                    o.onStatusChanged(this.task, oldStatus, status)
                });
            }
        }
    }

    onStatusChanged(status: TaskStatus) {
        switch (status) {
            case TaskStatus.PREPARING:
                this.task.observerDispatcher.notifyPreparing();
                break;
            case TaskStatus.RUNNING:
                this.task.observerDispatcher.notifyStart();
                break;
            case TaskStatus.WAITING:
                this.task.observerDispatcher.notifyWaiting();
                break;
            case TaskStatus.PAUSED:
                this.task.observerDispatcher.notifyPaused();
                break;
            case TaskStatus.ERROR:
                this.task.observerDispatcher.notifyError(this.getMessage());
                break;
            case TaskStatus.COMPLETE:
                this.task.observerDispatcher.notifyFinished();
                break;
        }

    }

    addObserver(observer: TaskStatusObserver) {
        if (!this.observers) {
            this.observers = [];
        }
        this.observers.push(observer);
    }

    removeObserver(observer: TaskStatusObserver) {
        if (this.observers) {
            let index = this.observers.indexOf(observer);
            if (index >= 0) {
                this.observers.splice(index, 1);
            }
        }
    }

    onError(message: string) {
        Logger.e(this, 'onError msg=' + message)
        this.setStatus(TaskStatus.ERROR, message);
    }
}