import Logger from '../../utils/Logger';
import TaskInfo from './TaskInfo';
import TaskObserverDispatcher from './TaskObserverDispatcher';
import TaskStatusManager from './TaskStatusManager';
import TaskManager from './TaskManager';
import TaskObserver from './TaskObserver';

/**
 * 任务状态
 */
export enum TaskStatus {
    CREATED = 0,
    PREPARING,
    WAITING,
    PROCESSING,
    PAUSED,
    ERROR,
    COMPLETE,
}

/**
 * 任务状态监听者
 */
export interface TaskStatusObserver {

    /**
     * 任务状态改变
     */
    onStatusChanged(task: Task, oldStatus: TaskStatus, status: TaskStatus): void;

}

/**
 * 任务抽象接口，根据不同类型的TaskInfo构建不同的任务
 * @author Z-P-J
 */
export default interface Task<T extends TaskInfo = TaskInfo> {

    /**
     * 管理该任务的任务管理器
     */
    readonly manager: TaskManager;

    /**
     * 任务状态管理器
     */
    readonly statusManager: TaskStatusManager

    /**
     * 任务观察者分发器
     */
    readonly observerDispatcher: TaskObserverDispatcher

    /**
     * 任务信息
     */
    readonly taskInfo: T

    /**
     * 获取父任务。该任务可能是某个任务的子任务，该方法将返回父任务，反之该方法返回null
     */
    getParentTask(): Task<TaskInfo>

    /**
     * 任务id
     */
    getTaskId(): number;

    /**
     * 任务名
     */
    getTaskName(): string;

    /**
     * 任务工作量
     */
    getTotalWorkload();

    /**
     * 已完成工作量
     */
    getCompleteWorkload();

    /**
     * 任务进度
     */
    getTaskProgress();

    /**
     * 任务速度
     */
    getTaskSpeed();

    /**
     * 任务信息
     */
    getMessage()

    /**
     * 添加任务观察者
     */
    addObserver(observer: TaskObserver);

    /**
     * 移除任务观察者
     */
    removeObserver(observer: TaskObserver): boolean;

    /**
     * 添加任务状态观察者
     */
    addStatusObserver(observer: TaskStatusObserver);

    /**
     * 移除任务状态观察者
     */
    removeStatusObserver(observer: TaskStatusObserver);

    /**
     * 暂停任务
     */
    pause();

    /**
     * 开始任务
     */
    start();

    /**
     * 移除任务
     */
    delete();

    /**
     * 获取任务状态
     */
    getStatus(): TaskStatus;

    /**
     * 任务是否在准备中
     */
    isPreparing(): boolean;

    /**
     * 任务是否准备完成
     */
    isPrepared(): boolean;

    /**
     * 任务是否在进行中
     */
    isProcessing(): boolean;

    /**
     * 任务是否在等待中
     */
    isWaiting(): boolean;

    /**
     * 任务是否已暂停
     */
    isPaused(): boolean;

    /**
     * 任务是否已完成
     */
    isComplete(): boolean;

    /**
     * 任务是否出错了
     */
    isError(): boolean;

    /**
     * 任务是否已停止，处于非运行态（pause、error、complete）
     */
    isStopped(): boolean

    /**
     * 任务是否可以暂停
     */
    canPause(): boolean;

    /**
     * 任务是否可以开始
     */
    canStart(): boolean;

    /**
     * 从本地恢复任务的逻辑
     */
    doRestore();

    /**
     * 初始化逻辑
     */
    doInit();

    /**
     * 等待等待逻辑
     */
    doWaiting();

    /**
     * 暂停逻辑
     */
    doPause();

    /**
     * 开始逻辑
     */
    doStart();

    /**
     * 删除逻辑
     */
    doDelete();

}

/**
 * 任务抽象类
 * @author Z-P-J
 */
export abstract class AbsTask<I extends TaskInfo = TaskInfo> implements Task<I> {
    /**
     * 管理该任务的任务管理器
     */
    readonly manager: TaskManager;

    /**
     * 任务状态管理器
     */
    readonly statusManager: TaskStatusManager

    /**
     * 任务观察者分发器
     */
    readonly observerDispatcher: TaskObserverDispatcher

    /**
     * 任务信息
     */
    readonly taskInfo: I

    constructor(manager: TaskManager, taskInfo: I) {
        this.manager = manager
        this.taskInfo = taskInfo
        this.statusManager = new TaskStatusManager(this)
        this.observerDispatcher = new TaskObserverDispatcher(this)
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

    getTaskName(): string {
        return this.taskInfo.taskName
    }

    getTotalWorkload() {
        return this.taskInfo.totalWorkload;
    }

    getCompleteWorkload() {
        return this.taskInfo.completeWorkload;
    }

    getTaskProgress() {
        return this.taskInfo.taskProgress;
    }

    getTaskSpeed() {
        // TODO 任务速度
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
        this.manager.delete(this)
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

    isProcessing(): boolean {
        return this.getStatus() == TaskStatus.PROCESSING;
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

    isStopped(): boolean {
        return this.canStart();
    }

    canPause(): boolean {
        return this.isProcessing() || this.isWaiting() || this.isPreparing();
    }

    canStart(): boolean {
        if (this.canPause()) {
            return false;
        }
        return this.isPaused() || this.isError() || this.getStatus() == TaskStatus.CREATED;
    }

    async doRestore(): Promise<void> {
        // do nothing
    }

    abstract doInit();

    abstract doWaiting();

    abstract doPause();

    abstract doStart();

    abstract doDelete();
}