import { MyTable } from '../decorator/Decorators';
import { Table } from '../decorator/Decorators';
import { SearchHistoryInfo } from '../../entity/SearchHistoryInfo';
import AbsTable from '../AbsTable';
import { ValuesBucket, ValueType } from '../AbsTable';
import rdb from '@ohos.data.relationalStore';

//@MyTable({
//  dbName: 'video_manager',
//  columns: [
//    {
//      name: 'id',
//      type: 'INTEGER',
//      isPrimaryKey: true,
//      autoIncrement: true,
//      unique: true,
//      notNull: true,
//    },
//    {
//      name: 'keyword',
//      type: 'TEXT',
//    },
//    {
//      name: 'accessTime',
//      type: 'INTEGER',
//    },
//  ] }
//)
@Table({ db: 'video_manager', name: 'search_history' })
export class SearchHistoryTable extends AbsTable<SearchHistoryInfo> {
  getColumnId(): string {
    return "id"
  }

  getTableColumns(): string[] {
    return ['id', 'keyword', 'accessTime']
  }

  getCreateTableSql(): string {
    return "CREATE TABLE IF NOT EXISTS search_history(id INTEGER PRIMARY KEY AUTOINCREMENT, keyword TEXT, accessTime INTEGER)"
  }

  bindToInsertValues(bucket: ValuesBucket, item: SearchHistoryInfo) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

  bindToContentValues(bucket: ValuesBucket, item: SearchHistoryInfo) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

  getEntityId(item: SearchHistoryInfo): ValueType {
    return item.id
  }

  createItem(cursor: rdb.ResultSet): SearchHistoryInfo {


    let info: SearchHistoryInfo = {
      id: cursor.getLong(cursor.getColumnIndex('id')),
      keyword: cursor.getString(cursor.getColumnIndex('keyword')),
      accessTime: cursor.getLong(cursor.getColumnIndex('accessTime'))
    }
    //    info['id'] = cursor.getLong(cursor.getColumnIndex('id'))
    //    info['keyword'] = cursor.getString(cursor.getColumnIndex('keyword'))
    //    info['accessTime'] = cursor.getLong(cursor.getColumnIndex('accessTime'))
    return info
  }
}