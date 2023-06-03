import { TaskStatus } from './Task';

/**
 * 任务信息
 */
export default class TaskInfo {

    /**
     * 任务id
     */
    readonly taskId: number;

    /**
     * 父任务id
     */
    readonly parentTaskId: number

    /**
     * 任务名
     */
    taskName: string

    /**
     * 任务状态
     */
    status: number = TaskStatus.CREATED

    /**
     * 总任务量
     * TODO 重命名
     */
    totalWorkload: number = 0;

    /**
     * 已完成任务量
     * TODO 重命名
     */
    completeWorkload: number = 0;

    /**
     * 任务进度
     * TODO 重命名为taskProgress
     */
    taskProgress: number = 0;

    /**
     * 任务创建时间
     */
    createTime: number = 0

    /**
     * 任务完成时间
     */
    finishedTime: number = 0

    /**
     * 任务是否准备完成
     */
    prepared: boolean = false;

    /**
     * 任务信息，一般用于保存错误信息
     */
    message: string = null;

    /**
     * 任务请求头信息，可用于自定义任务信息
     */
    header: Object = null



    constructor(taskId: number, parentTaskId: number, createTime: number = new Date().getTime()) {
        this.taskId = taskId
        this.parentTaskId = parentTaskId
        this.createTime = createTime
    }
}