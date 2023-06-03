import TaskInfo from './TaskInfo'

/**
 * 任务信息仓库，增删改查任务信息
 * @author Z-P-J
 */
export default interface TaskInfoRepository<T extends TaskInfo = TaskInfo> {

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