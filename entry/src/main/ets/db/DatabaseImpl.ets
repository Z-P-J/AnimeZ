import IDatabase from './IDatabase';
import AbsTable from './AbsTable';
import rdb from '@ohos.data.relationalStore';
import Logger from '../utils/Logger';
import HashMap from '@ohos.util.HashMap';
import 'reflect-metadata';

/**
 * 缓存数据库中的table
 */
export default class DatabaseImpl implements IDatabase {
    private readonly dbName
    private readonly tables = new HashMap<any, any>()

    constructor(dbName: string) {
        this.dbName = dbName
    }

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        let tableObj = this.tables.get(tableClass)
        if (!tableObj) {
            let tableName = Reflect.getMetadata('TableName', tableClass)
            Logger.e(this, 'getTable tableName=' + tableName)
            if (!tableName) {
                throw new Error('table name is empty')
            }

            tableObj = new tableClass(this.dbName, tableName)
            this.tables.set(tableClass, tableObj)
        }
        return tableObj
    }

//    private async getDatabase(): Promise<rdb.RdbStore> {
//        if (!this.db) {
//            this.db = await rdb.getRdbStore(getContext(this), { name: this.dbName, securityLevel: rdb.SecurityLevel.S1})
//        }
//        return this.db
//    }

}