import AbsTable from './AbsTable';

/**
 * 数据库接口
 */
export default interface IDatabase {

    /**
     * 获取数据库表对象
     */
    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T

}