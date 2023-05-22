import DownloadTaskInfo from './DownloadTaskInfo';
import { FileDownloadTask } from './FileDownloadTask';
import Logger from '../utils/Logger';
import { Table } from '../db/decorator/Decorators';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import AbsTable from '../db/AbsTable';
import { ValuesBucket, ValueType } from '../db/AbsTable';
import rdb from '@ohos.data.relationalStore';

/**
 * 下载管理
 */
@Table({ db: 'download_manager', name: 'download_tasks' })
export class FileDownloadTable extends AbsTable<DownloadTaskInfo> {
  getColumnId(): string {
    return 'taskId'
  }

  getTableColumns(): string[] {
    return ['taskId', 'parentTaskId', 'createTime', 'fileName', 'originalUrl', 'url', 'coverUrl', 'downloadDir',
      'totalSize', 'receivedSize', 'prepared', 'blockDownload', 'status', 'offset', 'contentLength']
  }

  getCreateTableSql(): string {
    return "CREATE TABLE IF NOT EXISTS download_tasks(taskId INTEGER PRIMARY KEY AUTOINCREMENT, parentTaskId INTEGER, createTime INTEGER" +
    ", fileName TEXT, originalUrl TEXT, url TEXT, coverUrl TEXT, downloadDir TEXT, totalSize INTEGER, receivedSize INTEGER" +
    ", prepared INTEGER, blockDownload INTEGER, status INTEGER, offset INTEGER, contentLength INTEGER, finishedTime INTEGER)"
  }

  bindToValuesBucket(bucket: ValuesBucket, item: DownloadTaskInfo) {
    this.getTableColumns().forEach((col) => {
      if (typeof item[col] == 'boolean') {
        bucket[col] = item[col] ? 1 : 0
      } else {
        bucket[col] = item[col]
      }
    })
  }

  getEntityId(item: DownloadTaskInfo): ValueType {
    return item.taskId
  }

  fileName: string
  downloadDir: string
  originalUrl: string
  url: string
  blockDownload: boolean = false

  createItem(cursor: rdb.ResultSet): DownloadTaskInfo {
    let taskId = cursor.getLong(cursor.getColumnIndex('taskId'))
    let parentTaskId = cursor.getLong(cursor.getColumnIndex('parentTaskId'))
    let createTime = cursor.getLong(cursor.getColumnIndex('createTime'))
    let info = new DownloadTaskInfo(taskId, parentTaskId, createTime)
    info['fileName'] = cursor.getString(cursor.getColumnIndex('fileName'))
    info['downloadDir'] = cursor.getString(cursor.getColumnIndex('downloadDir'))
    info['originalUrl'] = cursor.getString(cursor.getColumnIndex('originalUrl'))
    info['url'] = cursor.getString(cursor.getColumnIndex('url'))
    info['totalSize'] = cursor.getLong(cursor.getColumnIndex('totalSize'))
    info['receivedSize'] = cursor.getLong(cursor.getColumnIndex('receivedSize'))
    info['prepared'] = cursor.getLong(cursor.getColumnIndex('prepared')) == 1
    info['blockDownload'] = cursor.getLong(cursor.getColumnIndex('blockDownload')) == 1
    info['status'] = cursor.getLong(cursor.getColumnIndex('status'))
    info['offset'] = cursor.getLong(cursor.getColumnIndex('offset'))
    info['contentLength'] = cursor.getLong(cursor.getColumnIndex('contentLength'))
    info['finishedTime'] = cursor.getLong(cursor.getColumnIndex('finishedTime'))

//    info['coverUrl'] = cursor.getString(cursor.getColumnIndex('coverUrl'))
    return info
  }

  async queryById(taskId: number): Promise<DownloadTaskInfo> {
    Logger.e(this, 'queryById taskId=' + taskId)
    let items = await this.query(this.getPredicates().equalTo('taskId', taskId))
    return items[0]
  }

  async queryAllByParentId(parentTaskId: number): Promise<DownloadTaskInfo[]> {
    Logger.e(this, 'queryAllByParentId parentTaskId=' + parentTaskId)
    return this.query(this.getPredicates().equalTo('parentTaskId', parentTaskId))
  }

  async save(item: DownloadTaskInfo): Promise<number> {
    Logger.e(this, 'save item=' + JSON.stringify(item))
    let info = await this.queryById(item.taskId)
    Logger.e(this, 'save info=' + JSON.stringify(info))
    let result;
    if (info) {
      result = await this.update(item)
    } else {
      result = await this.insert(item)
    }
    Logger.e(this, 'saveOrUpdate result=' + result)
    return result
  }

}