import TaskInfo from './TaskInfo';
import TaskObserverDispatcher from './TaskObserverDispatcher';
import TaskStatusManager from './TaskStatusManager';
import TaskManager, { TaskStatus, TaskStatusObserver } from './TaskManager';
import TaskObserver from './TaskObserver';


//export default abstract class Task {
//
//    readonly manager: BaseTaskManager;
//
//    readonly statusManager: StatusManager = new StatusManager(this);
//
//    readonly observerDispatcher: ObserverDispatcher = new ObserverDispatcher(this);
//
//    readonly taskInfo: TaskInfo
//
//    constructor(manager: BaseTaskManager, taskInfo: TaskInfo) {
//        this.manager = manager;
//        this.taskInfo = taskInfo
//    }
//
//    getParentTask() {
//        if (this.manager) {
//            return this.manager.parentTask
//        }
//        return null;
//    }
//
//    getTaskId(): number {
//        return this.taskInfo.id
//    }
//
//    getTotalSize() {
//        return this.observerDispatcher.progressManager.totalSize;
//    }
//
//    getReceivedSize() {
//        return this.observerDispatcher.progressManager.receivedSize;
//    }
//
//    getProgress() {
//        return this.observerDispatcher.progressManager.downloadProgress;
//    }
//
//    getSpeed() {
//        // TODO
//    }
//
//    addObserver(observer: TaskObserver) {
//        this.observerDispatcher.addObserver(observer);
//    }
//
//    removeObserver(observer: TaskObserver): boolean {
//        return this.observerDispatcher.removeObserver(observer);
//    }
//
//    addStatusObserver(observer: TaskStatusObserver) {
//        this.statusManager.addObserver(observer)
//    }
//
//    removeStatusObserver(observer: TaskStatusObserver) {
//        this.statusManager.removeObserver(observer)
//    }
//
//    pause() {
//        if (this.manager) {
//            this.manager.pause(this)
//        }
//    }
//
//    start() {
//        if (this.manager) {
//            this.manager.start(this);
//        }
//    }
//
//    protected download() {
//        if (this.manager) {
//            this.manager.download(this);
//        }
//    }
//
//    getStatus(): TaskStatus {
//        return this.statusManager.getStatus();
//    }
//
//    isPreparing(): boolean {
//        return this.getStatus() == TaskStatus.PREPARING;
//    }
//
//    isPrepared(): boolean {
//        return this.taskInfo.prepared;
//    }
//
//    isRunning(): boolean {
//        return this.getStatus() == TaskStatus.RUNNING;
//    }
//
//    isWaiting(): boolean {
//        return this.getStatus() == TaskStatus.WAITING;
//    }
//
//    isPaused(): boolean {
//        return this.getStatus() == TaskStatus.PAUSED;
//    }
//
//    isComplete(): boolean {
//        return this.getStatus() == TaskStatus.COMPLETE;
//    }
//
//    isError(): boolean {
//        return this.getStatus() == TaskStatus.ERROR;
//    }
//
//    canPause(): boolean {
//        return this.isRunning() || this.isWaiting() || this.isPreparing();
//    }
//
//    canStart(): boolean {
//        if (this.canPause()) {
//            return false;
//        }
//        return this.isPaused() || this.isError() || this.getStatus() == TaskStatus.CREATED;
//    }
//
//    abstract doInit();
//
//    abstract doWaiting();
//
//    abstract doPause();
//
//    abstract doStart();
//
//}

export default interface Task<T extends TaskInfo = TaskInfo> {

    readonly manager: TaskManager;
    readonly statusManager: TaskStatusManager
    readonly observerDispatcher: TaskObserverDispatcher
    readonly taskInfo: T

    getParentTask(): Task<TaskInfo>

    getTaskId(): number;

    getTotalSize();

    getReceivedSize();

    getProgress();

    getSpeed();

    getMessage()

    addObserver(observer: TaskObserver);

    removeObserver(observer: TaskObserver): boolean;

    addStatusObserver(observer: TaskStatusObserver);

    removeStatusObserver(observer: TaskStatusObserver);

    pause();

    start();

    delete();

    getStatus(): TaskStatus;

    isPreparing(): boolean;

    isPrepared(): boolean;

    isRunning(): boolean;

    isWaiting(): boolean;

    isPaused(): boolean;

    isComplete(): boolean;

    isError(): boolean;

    canPause(): boolean;

    canStart(): boolean;

    doInit();

    doWaiting();

    doPause();

    doStart();

    doDelete();

}

export abstract class AbsTask<I extends TaskInfo = TaskInfo> implements Task<I> {
    readonly manager: TaskManager;

    readonly statusManager: TaskStatusManager = new TaskStatusManager(this);

    readonly observerDispatcher: TaskObserverDispatcher = new TaskObserverDispatcher(this);

    readonly taskInfo: I

    constructor(manager: TaskManager, taskInfo: I) {
        this.manager = manager
        this.taskInfo = taskInfo
    }

    getParentTask() {
        if (this.manager) {
            return this.manager.parentTask
        }
        return null;
    }

    getTaskId(): number {
        return this.taskInfo.taskId
    }

    getTotalSize() {
        return this.taskInfo.totalSize;
    }

    getReceivedSize() {
        return this.taskInfo.receivedSize;
    }

    getProgress() {
        return this.taskInfo.downloadProgress;
    }

    getSpeed() {
        // TODO
    }

    getMessage(): string {
        return this.taskInfo.message
    }

    addObserver(observer: TaskObserver) {
        this.observerDispatcher.addObserver(observer);
    }

    removeObserver(observer: TaskObserver): boolean {
        return this.observerDispatcher.removeObserver(observer);
    }

    addStatusObserver(observer: TaskStatusObserver) {
        this.statusManager.addObserver(observer)
    }

    removeStatusObserver(observer: TaskStatusObserver) {
        this.statusManager.removeObserver(observer)
    }

    pause() {
        if (this.manager) {
            this.manager.pause(this)
        }
    }

    start() {
        if (this.manager) {
            this.manager.start(this);
        }
    }

    delete() {

    }

    protected process() {
        if (this.manager) {
            this.manager.process(this);
        }
    }

    getStatus(): TaskStatus {
        return this.statusManager.getStatus();
    }

    isPreparing(): boolean {
        return this.getStatus() == TaskStatus.PREPARING;
    }

    isPrepared(): boolean {
        return this.taskInfo.prepared;
    }

    isRunning(): boolean {
        return this.getStatus() == TaskStatus.RUNNING;
    }

    isWaiting(): boolean {
        return this.getStatus() == TaskStatus.WAITING;
    }

    isPaused(): boolean {
        return this.getStatus() == TaskStatus.PAUSED;
    }

    isComplete(): boolean {
        return this.getStatus() == TaskStatus.COMPLETE;
    }

    isError(): boolean {
        return this.getStatus() == TaskStatus.ERROR;
    }

    canPause(): boolean {
        return this.isRunning() || this.isWaiting() || this.isPreparing();
    }

    canStart(): boolean {
        if (this.canPause()) {
            return false;
        }
        return this.isPaused() || this.isError() || this.getStatus() == TaskStatus.CREATED;
    }

    abstract doInit();

    abstract doWaiting();

    abstract doPause();

    abstract doStart();

    abstract doDelete();
}