
/**
 * 数据库表接口
 * TODO 改用装饰器配置
 */
export default interface ITable {

    /**
     * 获取数据库表名
     */
    getTableName(): string

    /**
     * 获取数据库主键
     */
    getColumnId(): string

    /**
     * 获取数据库表项
     */
    getTableColumns(): string[]

    /**
     * 获取创建表sql语句
     */
    getCreateTableSql(): string

}