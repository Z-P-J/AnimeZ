import { Property } from '../Property';

export class ToManyEntity{
    name: string;
    sourceEntityClsName: string;
    targetEntityClsName: string;
    sourceProperties: Property[];
    targetProperties: Property[];
    orderBy: string;

    tempList: Array<string> = []
}