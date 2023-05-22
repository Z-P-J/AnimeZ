import Globals from '../utils/Globals';
import DatabaseImpl from './DatabaseImpl';
import ITable from './ITable';
import AbsTable from './AbsTable';
import Logger from '../utils/Logger';

import HashMap from '@ohos.util.HashMap';
import 'reflect-metadata';

/**
 * 数据库操作类
 */
export default class SQLite {

    static init(context) {
        globalThis.sqliteContext = context
    }

    /**
     * 传入数据库表类，获取对应的表对象，进行相应的增删改查操作
     * @param tableClass
     */
    static with<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        let dbName = Reflect.getMetadata('Database', tableClass)
        if (!dbName) {
            throw new Error('table db is empty')
        }
        Logger.e(this, 'dbName=' + dbName)


        let database = Globals.getOrCreate(dbName, () => {
            return new DatabaseImpl(dbName);
        })
        return database.getTable(tableClass)


//        let globalDatabaseMap = Globals.get<HashMap<any, any>>('global_database_map', () => {
//            return new HashMap<any, any>()
//        })

//        let globalDatabaseMap = globalThis.globalDatabaseMap
//        Logger.e(this, 'globalDatabaseMap.class=' + globalDatabaseMap )
//
//        if (!globalDatabaseMap) {
//            globalDatabaseMap = {}
//            globalThis.globalDatabaseMap = globalDatabaseMap
//        }

//        Logger.e(this, 'globalDatabaseMap=' + JSON.stringify(globalDatabaseMap) )
//        let database = globalDatabaseMap.get(dbName)
//        Logger.e(this, 'database=' + database )
//        if (!(database instanceof DatabaseImpl)) {
//            database = new DatabaseImpl(dbName)
//            globalDatabaseMap.set(dbName, database)
//        }
//        Logger.e(this, 'getTable')
//        return database.getTable(tableClass)
    }

}