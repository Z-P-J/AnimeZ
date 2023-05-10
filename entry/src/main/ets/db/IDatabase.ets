import AbsTable from './AbsTable';

export default interface IDatabase {

    getTable<T extends AbsTable<any>>(tableClass: { new (dbName, tableName): T }): T

}