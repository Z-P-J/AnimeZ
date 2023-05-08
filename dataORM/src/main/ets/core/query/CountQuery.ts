/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import dataRdb from '@ohos.data.relationalStore';
import { AbstractQuery } from './AbstractQuery'
import { AbstractQueryData } from './AbstractQueryData'
import { AbstractDao } from '../AbstractDao'

export class CountQuery <T> extends AbstractQuery<T> {
    private queryData: QueryData<T>;
    
    static create<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates|string, initialValues: any[]): CountQuery<T2>{
        let queryData = new QueryData<T2>(dao, predicates, super.toStringArray(initialValues));
        return queryData.forCurrentThread();
    }

    constructor(queryData: QueryData<T>, dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates|string, initialValues: string[]) {
        super(dao, predicates, initialValues);
        this.queryData = queryData;
    }

    public forCurrentThread(): CountQuery<T>{
        return this.queryData.forCurrentThread();
    }

    //Returns the count (number of results matching the query). Uses SELECT COUNT (*) sematics.
    public async count(): Promise<number> {
        let cursor: any = await typeof this.predicates=='string'? this.dao.getDatabase().rawQuerys(<string>this.predicates): this.dao.getDatabase().rawQuery(<dataRdb.RdbPredicates>this.predicates);
        try {
            return cursor.rowCount;
        } finally {
            cursor.close();
        }

    }
    // copy setParameter methods to allow easy chaining
    public setParameter(index: number, parameter: any): CountQuery<T>{
        return <CountQuery<T>> super.setParameter(index, parameter);
    }

    public setParameterForDate(index: number, parameter: Date): CountQuery<T> {
        return <CountQuery<T>> super.setParameterForDate(index, parameter);
    }

    public setParameterForBoolean(index: number, parameter: boolean): CountQuery<T> {
        return <CountQuery<T>> super.setParameterForBoolean(index, parameter);
    }
}

class QueryData <T2> extends AbstractQueryData<T2, CountQuery<T2>> {
    constructor(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates|string, initialValues: string[]) {
        super(dao, predicates, initialValues);
    }

    createQuery(): CountQuery<T2>{
        return new CountQuery<T2>(this, this.dao, this.predicates, this.initialValues);
    }
}