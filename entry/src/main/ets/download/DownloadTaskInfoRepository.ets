import Logger from '../utils/Logger';
import SQLite from '../db/SQLite';
import DownloadTaskInfo from './DownloadTaskInfo';
import {FileDownloadTable} from './FileDownloadDao';
import TaskInfoRepository from './core/TaskInfoRepository';

export default class DownloadTaskInfoRepository implements TaskInfoRepository<DownloadTaskInfo> {

    async exists(taskInfo: DownloadTaskInfo): Promise<boolean> {
        if (SQLite.with(FileDownloadTable)
            .queryById(taskInfo.taskId)) {
            return true
        }
        return false
    }

    async create(taskInfo: DownloadTaskInfo): Promise<number> {
        Logger.e(this, 'create taskId=' + taskInfo.taskId)
        return SQLite.with(FileDownloadTable)
            .save(taskInfo)
    }

    async update(taskInfo: DownloadTaskInfo): Promise<number> {
        Logger.e(this, 'update taskInfo=' + JSON.stringify(taskInfo))
        return SQLite.with(FileDownloadTable)
            .update(taskInfo)
    }

    async delete(taskInfo: DownloadTaskInfo): Promise<number> {
        return SQLite.with(FileDownloadTable)
            .delete(taskInfo)
    }

    async queryAll(parentId: number): Promise<DownloadTaskInfo[]> {
        Logger.e(this, 'loadTasks parentId=' + parentId)
        return SQLite.with(FileDownloadTable)
            .queryAllByParentId(parentId)
    }

    async deleteAll(parentId: number): Promise<number> {
        let table = SQLite.with(FileDownloadTable)
        return table.deleteAll(table.getPredicates().equalTo('taskParentId', parentId))
    }

}