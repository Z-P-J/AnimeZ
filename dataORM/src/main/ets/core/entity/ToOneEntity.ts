import { Entity } from './Entity';
import { Property } from '../Property';

export class ToOneEntity {
    sourceEntityClsName: string;
    targetEntityClsName: string;
    name: string;
    fkProperties: Property[];

    tempList: Array<string> = [] // 临时存储
}