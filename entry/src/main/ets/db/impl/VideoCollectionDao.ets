import VideoCollectionInfo from '../../entity/VideoCollectionInfo';
import Logger from '../../utils/Logger';
import { Table } from '../decorator/Decorators';
import { VideoHistoryInfo } from '../../entity/VideoHistoryInfo';
import AbsTable from '../AbsTable';
import { ValuesBucket, ValueType } from '../AbsTable';
import rdb from '@ohos.data.relationalStore';

/**
 * 视频播放历史记录
 * TODO 通过装饰器配置数据库表信息
 * TODO 支持数据源key和数据源title
 */
@Table({ db: 'video_manager', name: 'video_collection' })
export class VideoCollectionTable extends AbsTable<VideoCollectionInfo> {
  getColumnId(): string {
    return "src"
  }

  getTableColumns(): string[] {
    return ['src', 'title', 'coverUrl', 'accessTime']
  }

  getCreateTableSql(): string {
    return "CREATE TABLE IF NOT EXISTS video_collection(src TEXT, title TEXT, coverUrl TEXT, accessTime INTEGER, PRIMARY KEY(src))"
  }

  getEntityId(item: VideoCollectionInfo): ValueType {
    return item.src
  }

  createItem(cursor: rdb.ResultSet): VideoCollectionInfo {
    let info = new VideoCollectionInfo()
    info['src'] = cursor.getString(cursor.getColumnIndex('src'))
    info['title'] = cursor.getString(cursor.getColumnIndex('title'))
    info['coverUrl'] = cursor.getString(cursor.getColumnIndex('coverUrl'))
    info['accessTime'] = cursor.getLong(cursor.getColumnIndex('accessTime'))
    return info
  }

  async queryBySrc(src: string): Promise<VideoCollectionInfo> {
    let items = await this.query(this.getPredicates().equalTo('src', src))
    return items[0]
  }

  async save(item: VideoCollectionInfo): Promise<number> {
    Logger.e(this, 'save item=' + JSON.stringify(item))
    let info = await this.queryBySrc(item.src)
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