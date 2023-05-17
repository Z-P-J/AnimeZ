import ITable from './ITable';
import rdb from '@ohos.data.relationalStore';
import Logger from '../utils/Logger';

export type ValueType = number | string | boolean | Uint8Array;

export type ValuesBucket = {
  [key: string]: ValueType | Uint8Array | null;
};

/**
 * 数据库表抽象类，实现ITable接口，封装常用的增删改查操作
 * TODO 通过装饰器配置columns、类型和primary key
 */
export default abstract class AbsTable<T> implements ITable {
  protected readonly tableName;
  private readonly dbName;
  private readonly futureDb: Promise<rdb.RdbStore>

  constructor(dbName: string, tableName: string) {
    this.dbName = dbName
    this.tableName = tableName
    this.futureDb = this.initDb()
  }

  private async initDb(): Promise<rdb.RdbStore> {
    Logger.e(this, 'initDb dbName=' + this.dbName + ' tableName=' + this.tableName)
    let db = await rdb.getRdbStore(getContext(this), {
      name: this.dbName,
      securityLevel: rdb.SecurityLevel.S1
    })
    Logger.e(this, 'initDb db=' + db)
    await db.executeSql(this.getCreateTableSql())
    Logger.e(this, 'initDb executeSql=' + this.getCreateTableSql())
    return db
  }

  getTableName(): string {
    return this.tableName
  }

  getPredicates() {
    return new rdb.RdbPredicates(this.tableName)
  }

  abstract getColumnId(): string

  abstract getTableColumns(): string[]

  abstract getCreateTableSql(): string

  bindToValuesBucket(bucket: ValuesBucket, item: T) {
    this.getTableColumns().forEach((col) => {
      bucket[col] = item[col]
    })
  }

//  abstract bindToContentValues(bucket: ValuesBucket, item: T);

  abstract createItem(cursor: rdb.ResultSet): T;

  abstract getEntityId(item: T): ValueType;

  /**
   * TODO 清空表
   */
  async clearTable(): Promise<void> {
    let db = await this.futureDb
    try {
      db.beginTransaction()
      await db.executeSql("delete from " + this.tableName)
      await db.executeSql("update sqlite_sequence SET seq = 0 where name ='" + this.tableName + "'")
      db.commit()
    } catch (e) {
      db.rollBack()
    }
  }

  /**
   * 插入数据
   * @param item
   */
  async insert(item: T): Promise<number> {
    let bucket = {}
    this.bindToValuesBucket(bucket, item)

    let db = await this.futureDb
    return db.insert(this.tableName, bucket)
  }

  /**
   * 删除数据
   * @param item
   */
  async delete(item: T): Promise<number> {
    let predicates = this.getPredicates()
      .equalTo(this.getColumnId(), this.getEntityId(item))

    let db = await this.futureDb
    return db.delete(predicates)
  }

  /**
   * 更新数据
   * @param item
   */
  async update(item: T, predicates?: rdb.RdbPredicates): Promise<number> {
    let bucket = {}
    this.bindToValuesBucket(bucket, item)
    Logger.e(this, 'update bucket=' + JSON.stringify(bucket))
    bucket[this.getColumnId()] = undefined
    let db = await this.futureDb
    if (!predicates) {
      predicates = this.getPredicates().equalTo(this.getColumnId(), this.getEntityId(item))
    }
    return db.update(bucket, predicates)
  }

  /**
   * 查询所有数据
   */
  async queryAll(): Promise<T[]> {
    return this.query(this.getPredicates(), this.getTableColumns())
    //    Logger.e(this, 'queryAll')
    //    let db = await this.futureDb
    //    let resultSet = await db.querySql("SELECT * from " + this.tableName)
    //    let items = []
    //    if (resultSet.goToFirstRow()) {
    //      do {
    //        Logger.e(this, 'queryAll rowIndex=' + resultSet.rowIndex)
    //        items.push(this.createItem(resultSet))
    //      } while (resultSet.goToNextRow())
    //    }
    //    return items;
  }

  async query(predicates: rdb.RdbPredicates, columns?: Array<string>): Promise<T[]> {
    Logger.e(this, 'queryAll')
    let db = await this.futureDb
    let resultSet = await db.query(predicates, columns)
    let items = []
    if (resultSet.goToFirstRow()) {
      do {
        Logger.e(this, 'queryAll rowIndex=' + resultSet.rowIndex)
        items.push(this.createItem(resultSet))
      } while (resultSet.goToNextRow())
    }
    Logger.e(this, 'queryAll items=' + JSON.stringify(items))
    return items;
  }
}