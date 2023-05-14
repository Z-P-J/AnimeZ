import AbsTable from './AbsTable';

/**
 * 数据库接口
 */
export default interface IDatabase {

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T

}