import Globals from '../utils/Globals';
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
    private readonly key
//    private readonly tables = new HashMap<any, any>()

    constructor(dbName: string) {
        this.dbName = dbName
        this.key = "table_map_" + this.dbName
    }

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        return Globals.getOrCreate(tableClass, () => {
            let tableName = Reflect.getMetadata('TableName', tableClass)
            Logger.e(this, 'getTable tableName=' + tableName)
            if (!tableName) {
                throw new Error('table name is empty')
            }
            return new tableClass(this.dbName, tableName)
        })


//        let tables = Globals.get<HashMap<any, any>>(this.key, () => {
//            return new HashMap<any, any>()
//        })
//        let tableObj = tables.get(tableClass)
//        if (!tableObj) {
//            let tableName = Reflect.getMetadata('TableName', tableClass)
//            Logger.e(this, 'getTable tableName=' + tableName)
//            if (!tableName) {
//                throw new Error('table name is empty')
//            }
//
//            tableObj = new tableClass(this.dbName, tableName)
//            tables.set(tableClass, tableObj)
//        }
//        return tableObj
    }

//    private async getDatabase(): Promise<rdb.RdbStore> {
//        if (!this.db) {
//            this.db = await rdb.getRdbStore(getContext(this), { name: this.dbName, securityLevel: rdb.SecurityLevel.S1})
//        }
//        return this.db
//    }

}