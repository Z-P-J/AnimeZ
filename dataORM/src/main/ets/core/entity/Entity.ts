import { ToManyWithJoinEntity } from './ToManyWithJoinEntity';
import { ToManyEntity } from './ToManyEntity';
import { ToOneEntity } from './ToOneEntity';
import { Property } from '../Property';

export class Entity {
    className: string; //类名
    dbName: string; //表名
    pkProperty: Property; //主键属性
    toOneRelations: Array<ToOneEntity>; //一对一集合
    toManyRelations: Array<ToManyEntity>; //一对多集合
    incomingToManyRelations: Array<ToManyEntity>; //一对多集合

    joinEntityTempList: Array<any> // 临时存储
}