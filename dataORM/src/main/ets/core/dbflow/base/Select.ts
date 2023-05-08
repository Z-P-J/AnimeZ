/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
    *
  * http://www.apache.org/licenses/LICENSE-2.0
    *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

//@ts-nocheck
import dataRdb from '@ohos.data.relationalStore'
import { AbstractDao } from '../../AbstractDao'

/**
 *  此类作为dataRdb.RdbPredicatesV9  的包装
 * @param db
 * @param tableName
 */
type ValueType = number | string | boolean;

export class Select <Model> {
    private predicates: dataRdb.RdbPredicates
    private model: Model;
    private daoSession;
    private eqMapKey: Map<string, any>;

    constructor() {
        this.eqMapKey = new Map<string, any>();
        this.daoSession = globalThis.daoSession;
    }

    public from(model: Model) {
        let tableName = AbstractDao.TABLENAME(model)
        this.predicates = new dataRdb.RdbPredicates(tableName)
        return this;
    }

    public eq(columnName: string, value: ValueType): Select{
        this.eqMapKey.set(columnName, value);
        this.predicates.equalTo(columnName, value);
        return this;
    }

    public notEq(columnName: string, value: ValueType): Select{
        this.predicates.notEqualTo(columnName, value)
        return this;
    }

    public beginWrap(): Select{
        this.predicates.beginWrap()
        return this;
    }

    public endWrap(): Select{
        this.predicates.endWrap();
        return this;
    }

    public or(): Select{
        this.predicates.or();
        return this;
    }

    public and(): Select {
        this.predicates.and();
        return this;
    }

    public contains(columnName: string, value: string): Select{
        this.predicates.contains(columnName, value);
        return this;

    }

    public beginsWith(columnName: string, value: string): Select{
        this.predicates.beginsWith(columnName, value)
        return this;
    }

    public endsWith(columnName: string, value: string): Select{
        this.predicates.endsWith(columnName, value)
        return this;

    }

    public isNull(value: string): Select{
        this.predicates.isNull(value);
        return this;

    }

    public isNotNull(value: string): Select {
        this.predicates.isNotNull(value);
        return this;

    }

    public like(columnName: string, value: string): Select {
        this.predicates.like(columnName, value);
        return this;

    }

    public glob(columnName: string, value: string): Select{
        this.predicates.glob(columnName, value);
        return this;
    }

    public between(value: string, low: ValueType, high: ValueType): Select{
        this.predicates.between(value, low, high);
        return this;

    }

    public notBetween(value: string, low: ValueType, high: ValueType): Select{
        this.predicates.notBetween(value, low, high);
        return this;
    }

    public greaterThan(columnName: string, value: ValueType): Select{
        this.predicates.greaterThan(columnName, value);
        return this;
    }

    public lessThan(columnName: string, value: ValueType): Select{
        this.predicates.lessThan(columnName, value)
        return this;

    }

    public greaterThanOrEq(columnName: string, value: ValueType): Select{
        this.predicates.greaterThanOrEqualTo(columnName, value);
        return this;
    }

    public lessThanOrEq(columnName: string, value: ValueType): Select {
        this.predicates.lessThanOrEqualTo(columnName, value)
        return this;
    }

    public orderByAsc(columnName: string): Select {
        this.predicates.orderByAsc(columnName)
        return this;

    }

    public orderByDesc(columnName: string): Select{
        this.predicates.orderByDesc(columnName)
        return this;
    }

    public distinct(): Select{
        this.predicates.distinct();
        return this;

    }

    public limit(value: number): Select {
        this.predicates.limitAs(value)
        return this;
    }

    public offset(rowOffset: number): Select{
        this.predicates.offsetAs(rowOffset);
        return this;

    }

    public groupBy(value: Array<string>): Select{
        this.predicates.groupBy(value);
        return this;

    }

    public indexedBy(columnName: string): Select{
        this.predicates.indexedBy(columnName)
        return this;
    }

    public inData(columnName: string, value: Array<ValueType>): Select{
        this.predicates.in(columnName, value);
        return this;
    }

    public notIn(columnName: string, value: Array<ValueType>): Select{
        this.predicates.notIn(columnName, value);
        return this;

    }

    public build(): any{
        return this.predicates
    }

    public getKeyMaps(): Map<string, any>{
        return this.eqMapKey;
    }

    public querySingle(entityCls: any): Promise<Array<any>>{
        return this.daoSession.getBaseDao(entityCls).query(this.limit(1))

    }

    public query(entityCls: any): Promise<Array<any>>{
        return this.daoSession.getBaseDao(entityCls).query(this)
    }
}

