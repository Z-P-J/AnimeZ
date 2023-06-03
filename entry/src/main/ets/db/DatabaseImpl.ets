import Globals from '../utils/Globals';
import IDatabase from './IDatabase';
import AbsTable from './AbsTable';
import Logger from '../utils/Logger';
import 'reflect-metadata';

/**
 * 缓存数据库中的table
 */
export default class DatabaseImpl implements IDatabase {
    private readonly dbName
    private readonly key

    constructor(dbName: string) {
        this.dbName = dbName
        this.key = "table_map_" + this.dbName
    }

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T {
        return Globals.getOrCreate(this.dbName + '_' + tableClass.name, () => {
            let tableName = Reflect.getMetadata('TableName', tableClass)
            Logger.e(this, 'getTable tableName=' + tableName)
            if (!tableName) {
                throw new Error('table name is empty')
            }
            return new tableClass(this.dbName, tableName)
        })
    }

}