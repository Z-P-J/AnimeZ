import ColumnInfo from '../ColumnInfo';

import 'reflect-metadata';

export function Table(v: {db: string, name: string}): ClassDecorator {
    return (target) => {
        Reflect.defineMetadata('Database',v.db, target);
        Reflect.defineMetadata('TableName', v.name, target);
    };
}


export function MyTable(v: {dbName: string, columns: ColumnInfo[]}): ClassDecorator {
    return (target) => {
        Reflect.defineMetadata('dbName',v.dbName, target);
        Reflect.defineMetadata('columns', v.columns, target);
    };
}