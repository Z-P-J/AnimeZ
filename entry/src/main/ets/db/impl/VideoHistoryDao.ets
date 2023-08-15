import Logger from '../../utils/Logger';
import { Table } from '../decorator/Decorators';
import { VideoHistoryInfo } from '../../entity/VideoHistoryInfo';
import AbsTable from '../AbsTable';
import { ValuesBucket, ValueType } from '../AbsTable';
import rdb from '@ohos.data.relationalStore';

/**
 * 视频播放历史记录
 * TODO 通过装饰器配置数据库表信息
 */
@Table({ db: 'video_manager', name: 'video_history' })
export class VideoHistoryTable extends AbsTable<VideoHistoryInfo> {
  getColumnId(): string {
    return "link"
  }

  getTableColumns(): string[] {
    return ['link', 'title', 'totalTime', 'currentTime', 'coverUrl', 'episodeListIndex',
      'episodeIndex', 'episodeName', 'videoUrl', 'videoProgress', 'sourceKey', 'accessTime']
  }

  getCreateTableSql(): string {
    return "CREATE TABLE IF NOT EXISTS video_history(link TEXT, title TEXT, totalTime INTEGER, currentTime INTEGER, " +
    "coverUrl TEXT, episodeListIndex INTEGER, episodeIndex INTEGER, episodeName TEXT, videoUrl TEXT, " +
    "videoProgress INTEGER, sourceKey TEXT, accessTime INTEGER, PRIMARY KEY(link))"
  }

  bindToValuesBucket(bucket: ValuesBucket, item: VideoHistoryInfo) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

//  bindToContentValues(bucket: ValuesBucket, item: VideoHistoryInfo) {
//    this.getTableColumns().forEach((col) => {
//      bucket[col] = item[col]
//    })
//  }

  getEntityId(item: VideoHistoryInfo): ValueType {
    return item.link
  }

  createItem(cursor: rdb.ResultSet): VideoHistoryInfo {
    let info = new VideoHistoryInfo()
    info['link'] = cursor.getString(cursor.getColumnIndex('link'))
    info['title'] = cursor.getString(cursor.getColumnIndex('title'))
    info['totalTime'] = cursor.getLong(cursor.getColumnIndex('totalTime'))
    info['currentTime'] = cursor.getLong(cursor.getColumnIndex('currentTime'))
    info['coverUrl'] = cursor.getString(cursor.getColumnIndex('coverUrl'))
    info['episodeListIndex'] = cursor.getLong(cursor.getColumnIndex('episodeListIndex'))
    info['episodeIndex'] = cursor.getLong(cursor.getColumnIndex('episodeIndex'))
    info['episodeName'] = cursor.getString(cursor.getColumnIndex('episodeName'))
    info['videoUrl'] = cursor.getString(cursor.getColumnIndex('videoUrl'))
    info['videoProgress'] = cursor.getLong(cursor.getColumnIndex('videoProgress'))
    info['sourceKey'] = cursor.getString(cursor.getColumnIndex('sourceKey'))
    info['accessTime'] = cursor.getLong(cursor.getColumnIndex('accessTime'))
    return info
  }

  async queryAllByAsc(): Promise<VideoHistoryInfo[]> {
    return this.queryAll(this.getPredicates().orderByAsc(this.getColumnId()))
  }

  async queryAllByAccessTimeDesc(): Promise<VideoHistoryInfo[]> {
    return this.queryAll(this.getPredicates().orderByDesc('accessTime'))
  }

  async queryByLink(link: string): Promise<VideoHistoryInfo> {
    let items = await this.query(this.getPredicates().equalTo('link', link))
    return items[0]
  }

  async save(item: VideoHistoryInfo): Promise<number> {
    Logger.e(this, 'save item=' + JSON.stringify(item))
    let info = await this.queryByLink(item.link)
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