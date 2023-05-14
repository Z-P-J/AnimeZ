
/**
 * 数据库表接口
 */
export default interface ITable {

    getTableName(): string

    getColumnId(): string

    getTableColumns(): string[]

    getCreateTableSql(): string

}