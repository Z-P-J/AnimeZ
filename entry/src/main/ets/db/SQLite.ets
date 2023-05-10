import AbsDatabase from './AbsDatabase';
import ITable from './ITable';
import AbsTable from './AbsTable';
import Logger from '../utils/Logger';

import HashMap from '@ohos.util.HashMap';
import 'reflect-metadata';

export default class SQLite {

    static init(context) {
        globalThis.sqliteContext = context
    }

    static with<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        let dbName = Reflect.getMetadata('Database', tableClass)
        if (!dbName) {
            throw new Error('table db is empty')
        }
        Logger.e(this, 'dbName=' + dbName)

//        let globalDatabaseMap = globalThis.globalDatabaseMap
//        Logger.e(this, 'globalDatabaseMap.class=' + globalDatabaseMap )
//        if (!(globalDatabaseMap instanceof HashMap)) {
//            globalDatabaseMap = new HashMap()
//            globalThis.globalDatabaseMap = globalDatabaseMap
//        }
//        Logger.e(this, 'globalDatabaseMap=' + globalDatabaseMap.constructor )
//        let database = globalDatabaseMap.get(dbName)
//        Logger.e(this, 'database=' + database )
//        if (!(database instanceof AbsDatabase)) {
//            database = new AbsDatabase(dbName)
//            globalDatabaseMap.push(dbName, database)
//        }
//        return database.getTable(Table)

        let globalDatabaseMap = globalThis.globalDatabaseMap
        Logger.e(this, 'globalDatabaseMap.class=' + globalDatabaseMap )

        if (!globalDatabaseMap) {
            globalDatabaseMap = {}
            globalThis.globalDatabaseMap = globalDatabaseMap
        }

        Logger.e(this, 'globalDatabaseMap=' + JSON.stringify(globalDatabaseMap) )
        let database = globalDatabaseMap[dbName]
        Logger.e(this, 'database=' + database )
        if (!(database instanceof AbsDatabase)) {
            database = new AbsDatabase(dbName)
            globalDatabaseMap[dbName] = database
        }
        Logger.e(this, 'getTable')
        return database.getTable(tableClass)
    }

}