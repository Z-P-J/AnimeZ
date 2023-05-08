import { Entity } from './Entity'
import { ToManyEntity } from './ToManyEntity'

export class ToManyWithJoinEntity extends ToManyEntity {
    joinEntity: Entity;
}