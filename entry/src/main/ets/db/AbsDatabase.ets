import IDatabase from './IDatabase';
import AbsTable from './AbsTable';
import rdb from '@ohos.data.relationalStore';
import Logger from '../utils/Logger';
import HashMap from '@ohos.util.HashMap';
import 'reflect-metadata';

export class FutureDatabase {

    private readonly dbName

    private db: rdb.RdbStore

    constructor(dbName: string) {
        this.dbName = dbName
    }

    async getDatabase(): Promise<rdb.RdbStore> {
        if (!this.db) {
            this.db = await rdb.getRdbStore(getContext(this), { name: this.dbName, securityLevel: rdb.SecurityLevel.S1})
        }
        return this.db
    }

}

export default class AbsDatabase implements IDatabase {
    private readonly dbName
    private readonly tables = new HashMap<any, any>()
//    private db: rdb.RdbStore

    constructor(dbName: string) {
        this.dbName = dbName
//        this.getDatabase()
    }

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        let tableObj = this.tables.get(tableClass)
        if (!tableObj) {
//            let db = await this.getDatabase()

            let tableName = Reflect.getMetadata('TableName', tableClass)
            Logger.e(this, 'getTable tableName=' + tableName)
            if (!tableName) {
                throw new Error('table name is empty')
            }

            tableObj = new tableClass(this.dbName, tableName)
//            await db.executeSql(tableObj.getCreateTableSql())
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