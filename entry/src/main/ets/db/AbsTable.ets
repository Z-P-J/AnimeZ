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
  protected readonly futureDb: Promise<rdb.RdbStore>

  constructor(dbName: string, tableName: string) {
    this.dbName = dbName
    this.tableName = tableName
    this.futureDb = this.initDb()
  }

  /**
   * 获取并初始化数据库
   */
  private async initDb(): Promise<rdb.RdbStore> {
    Logger.e(this, 'initDb dbName=' + this.dbName + ' tableName=' + this.tableName)
    let db = await rdb.getRdbStore(getContext(this), {
      name: this.dbName,
      securityLevel: rdb.SecurityLevel.S1
    })
    Logger.e(this, 'initDb db=' + db)
    await this.init(db)
    Logger.e(this, 'initDb executeSql=' + this.getCreateTableSql())
    return db
  }

  /**
   * 初始化数据库
   * @param db
   */
  protected async init(db: rdb.RdbStore): Promise<void> {
    return db.executeSql(this.getCreateTableSql())
  }

  /**
   * 获取表名
   */
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

  abstract createItem(cursor: rdb.ResultSet): T;

  abstract getEntityId(item: T): ValueType;

  /**
   * 清空表
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
    return this.deleteAll(predicates)
  }

  async deleteItems(...items: T[]): Promise<number[]> {
    if (!items) {
      return []
    }
    const results: number[] = []
    for (const item of items) {
      let predicates = this.getPredicates()
        .equalTo(this.getColumnId(), this.getEntityId(item))
      results.push(await this.deleteAll(predicates))
    }
    return results
  }

  /**
   * 删除数据
   * @param item
   */
  async deleteAll(predicates: rdb.RdbPredicates): Promise<number> {
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
  async queryAll(predicates?: rdb.RdbPredicates): Promise<T[]> {
    if (!predicates) {
      predicates = this.getPredicates()
    }
    return this.query(predicates, this.getTableColumns())
  }

  /**
   * 根据条件查询数据
   * @param predicates
   * @param columns
   */
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