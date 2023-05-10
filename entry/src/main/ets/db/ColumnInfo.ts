
export enum ValueType {
    TEXT, INTEGER, LONG
}

export default interface ColumnInfo {

    name: string,
    type: 'TEXT' | 'INTEGER',
    isPrimaryKey?: boolean,
    autoIncrement?: boolean,
    unique?: boolean,
    notNull?: boolean,
    defaultValue?: ValueType

}