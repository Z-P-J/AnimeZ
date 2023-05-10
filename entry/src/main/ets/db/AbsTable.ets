import ITable from './ITable';
import rdb from '@ohos.data.relationalStore';
import Logger from '../utils/Logger';

export type ValueType = number | string | boolean | Uint8Array;

export type ValuesBucket = {
  [key: string]: ValueType | Uint8Array | null;
};

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

  abstract getColumnId(): string

  abstract getTableColumns(): string[]

  abstract getCreateTableSql(): string

  abstract bindToInsertValues(bucket: ValuesBucket, item: T);

  abstract bindToContentValues(bucket: ValuesBucket, item: T);

  abstract createItem(cursor: rdb.ResultSet): T;

  abstract getEntityId(item: T): ValueType;


  async insert(item: T): Promise<number> {
    let bucket = {}
    this.bindToInsertValues(bucket, item)

    let db = await this.futureDb
    let result = await db.insert(this.tableName, bucket)
    return result
  }

  async update(item: T): Promise<number> {
    let bucket = {}
    this.bindToInsertValues(bucket, item)

    let db = await this.futureDb

    let predicates =  new rdb.RdbPredicates(this.tableName)
      .equalTo(this.getColumnId(), this.getEntityId(item))
    let result = await db.update(bucket, predicates)
    return result
  }

  async queryAll(): Promise<T[]> {
    Logger.e(this, 'queryAll')
    let db = await this.futureDb
    let resultSet = await db.querySql("SELECT * from " + this.tableName)
    let items = []
    if (resultSet.goToFirstRow()) {
      do {
        Logger.e(this, 'queryAll rowIndex=' + resultSet.rowIndex)
        items.push(this.createItem(resultSet))
      } while (resultSet.goToNextRow())
    }
    return items;
  }
}