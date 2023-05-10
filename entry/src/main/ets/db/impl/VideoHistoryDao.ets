import { Table } from '../decorator/Decorators';
import { VideoHistoryInfo } from '../../entity/VideoHistoryInfo';
import AbsTable from '../AbsTable';
import {ValuesBucket, ValueType} from '../AbsTable';
import rdb from '@ohos.data.relationalStore';

@Table({db: 'video_manager', name: 'video_history'})
export class VideoHistoryTable extends AbsTable<VideoHistoryInfo> {

  getColumnId(): string {
    return "link"
  }

  getTableColumns(): string[] {
    return ['link', 'title', 'lastTime', 'coverUrl', 'episodeListIndex', 'episodeIndex', 'episodeName', 'videoUrl', 'videoProgress']
  }

  getCreateTableSql(): string {
    return "CREATE TABLE IF NOT EXISTS video_history(link TEXT, title TEXT, lastTime INTEGER, " +
    "coverUrl TEXT, episodeListIndex INTEGER, episodeIndex INTEGER, episodeName TEXT, videoUrl TEXT, " +
    "videoProgress INTEGER, PRIMARY KEY(link))"
  }

  bindToInsertValues(bucket: ValuesBucket, item: VideoHistoryInfo) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

  bindToContentValues(bucket: ValuesBucket, item: VideoHistoryInfo) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

  getEntityId(item: VideoHistoryInfo): ValueType {
    return item.link
  }

  createItem(cursor: rdb.ResultSet): VideoHistoryInfo {
    let info = new VideoHistoryInfo()
    info['link'] = cursor.getString(cursor.getColumnIndex('link'))
    info['title'] = cursor.getString(cursor.getColumnIndex('title'))
    info['lastTime'] = cursor.getLong(cursor.getColumnIndex('lastTime'))
    info['coverUrl'] = cursor.getString(cursor.getColumnIndex('coverUrl'))
    info['episodeListIndex'] = cursor.getLong(cursor.getColumnIndex('episodeListIndex'))
    info['episodeIndex'] = cursor.getLong(cursor.getColumnIndex('episodeIndex'))
    info['episodeName'] = cursor.getString(cursor.getColumnIndex('episodeName'))
    info['videoUrl'] = cursor.getString(cursor.getColumnIndex('videoUrl'))
    info['videoProgress'] = cursor.getLong(cursor.getColumnIndex('videoProgress'))
    return info
  }

}