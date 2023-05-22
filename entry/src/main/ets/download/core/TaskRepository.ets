import TaskInfo from './TaskInfo'


export default interface TaskRepository<T extends TaskInfo = TaskInfo> {

    /**
     * 查询所有下载任务
     */
    queryAll(parentId: number): Promise<T[]>

    /**
     * 判断下载任务是否存在
     */
    exists(taskInfo: T): Promise<boolean>

    /**
     * 创建下载任务
     */
    create(taskInfo: T): Promise<number>

    /**
     * 更新下载任务
     */
    update(taskInfo: T): Promise<number>

    /**
     * 删除下载任务
     */
    delete(taskInfo: T): Promise<number>

    /**
     * 删除下载任务
     */
    deleteAll(parentId: number): Promise<number>
}