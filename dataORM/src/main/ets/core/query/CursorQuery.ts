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

import dataRdb from '@ohos.data.relationalStore'
import { AbstractQueryData } from './AbstractQueryData'
import { AbstractDao } from '../AbstractDao'
import { AbstractQueryWithLimit } from './AbstractQueryWithLimit'

export class CursorQuery<T> extends AbstractQueryWithLimit<T> {
    private queryData: QueryData<T> ;

    /** For internal use by dataORM only. */
    public static internalCreate<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates, initialValues: any[]): CursorQuery<T2> {
        return this.create(dao, predicates, initialValues, -1, -1);
    }

    static create<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: any[], limitPosition: number,
                      offsetPosition: number): CursorQuery<T2> {
        let queryData = new QueryData<T2>(dao, predicates, super.toStringArray(initialValues), limitPosition, offsetPosition);
        return queryData.forCurrentThread();
    }

    constructor(queryData: QueryData<T>, dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates | string, initialValues: string[], limitPosition: number,
                offsetPosition: number) {
        super(dao, predicates, initialValues, limitPosition, offsetPosition);
        this.queryData = queryData;
    }

    public forCurrentThread(): CursorQuery<T> {
        return this.queryData.forCurrentThread();
    }

    /** Executes the query and returns a raw database.Cursor. Don't forget to close it. */
    public async query(): Promise<any> {
        return await typeof this.predicates == 'string' ? this.dao.getDatabase().rawQuerys(<string> this.predicates, this.parameters) : this.dao.getDatabase().rawQuery(<dataRdb.RdbPredicates> this.predicates, this.parameters);
    }

    // copy setParameter methods to allow easy chaining
    public setParameter(index: number, parameter: any): CursorQuery<T> {
        return <CursorQuery<T>> super.setParameter(index, parameter);
    }

    public setParameterForDate(index: number, parameter: Date): CursorQuery<T> {
        return <CursorQuery<T>> super.setParameterForDate(index, parameter);
    }

    public setParameterForBoolean(index: number, parameter: boolean): CursorQuery<T> {
        return <CursorQuery<T>> super.setParameterForBoolean(index, parameter);
    }
}

class QueryData<T2> extends AbstractQueryData<T2, CursorQuery<T2>> {
    private limitPosition: number;
    private offsetPosition: number;

    constructor(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: string[], limitPosition: number, offsetPosition: number) {
        super(dao, predicates, initialValues);
        this.limitPosition = limitPosition;
        this.offsetPosition = offsetPosition;
    }

    createQuery(): CursorQuery<T2> {
        return new CursorQuery<T2>(this, this.dao, this.predicates, this.initialValues, this.limitPosition, this.offsetPosition);
    }
}