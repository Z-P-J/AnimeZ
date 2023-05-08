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
import { AbstractDao } from '../AbstractDao'
import { AbstractQueryWithLimit } from './AbstractQueryWithLimit'
import { AbstractQueryData } from './AbstractQueryData'

export class Query<T> extends AbstractQueryWithLimit<T> {
    private queryData: QueryData<T> ;

    /** For internal use by dataORM only. */
    public static internalCreate<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates, initialValues: any[]): Query<T2> {
        return this.create(dao, predicates, initialValues, -1, -1);
    }

    static create<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: any[], limitPosition: number,
                      offsetPosition: number): Query<T2> {
        let queryData = new QueryData<T2>(dao, predicates, super.toStringArray(initialValues), limitPosition,
            offsetPosition);
        return queryData.forCurrentThread();
    }

    constructor(queryData: QueryData<T>, dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates | string, initialValues: string[], limitPosition: number,
                offsetPosition: number) {
        super(dao, predicates, initialValues, limitPosition, offsetPosition);
        this.queryData = queryData;
    }

    /**
     * Note: all parameters are reset to their initial values specified in {@link QueryBuilder}.
     */
    public forCurrentThread(): Query<T> {
        return this.queryData.forCurrentThread();
    }

    /** Executes the query and returns the result as a list containing all entities loaded into memory. */
    public async list(): Promise<Array<T>> {
        let cursor: any
        if (typeof this.predicates == "string") {
            cursor = await this.dao.getDatabase().rawQuerys(<string> this.predicates, this.dao.getAllColumns())
        } else {
            cursor = await this.dao.getDatabase().rawQuery(<dataRdb.RdbPredicates> this.predicates, this.dao.getAllColumns());
        }
        return this.daoAccess.loadAllAndCloseCursor(cursor);
    }

    public async listSql(): Promise<Array<T>> {
        let cursor: any = await this.dao.getDatabase().rawQuerys(<string> this.predicates, this.parameters);
        return this.daoAccess.loadAllAndCloseCursor(cursor);
    }
    /**
     * Executes the query and returns the unique result or null.
     *
     * @return Entity or null if no matching entity was found
     * @throws DaoException if the result is not unique
     */
    public unique(): T {
        let cursor: any
        if (typeof this.predicates == "string") {
            cursor = this.dao.getDatabase().rawQuerys(<string> this.predicates, this.parameters)
        } else {
            cursor = this.dao.getDatabase().rawQuery(<dataRdb.RdbPredicates> this.predicates, this.parameters);
        }
        return this.daoAccess.loadUniqueAndCloseCursor(cursor);
    }

    /**
     * Executes the query and returns the unique result (never null).
     *
     * @return Entity
     * @throws DaoException if the result is not unique or no entity was found
     */
    public uniqueOrThrow(): T {
        let entity: T = this.unique();
        if (entity == null) {
            throw new Error("No entity found for query");
        }
        return entity;
    }

    public setParameter(index: number, parameter: any): Query<T> {
        return <Query<T>> super.setParameter(index, parameter);
    }

    public setParameterForDate(index: number, parameter: Date): Query<T> {
        return <Query<T>> super.setParameterForDate(index, parameter);
    }

    public setParameterForBoolean(index: number, parameter: boolean): Query<T> {
        return <Query<T>> super.setParameterForBoolean(index, parameter);
    }
}

class QueryData<T2> extends AbstractQueryData<T2, Query<T2>> {
    private limitPosition: number;
    private offsetPosition: number;

    constructor(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: string[], limitPosition: number, offsetPosition: number) {
        super(dao, predicates, initialValues);
        this.limitPosition = limitPosition;
        this.offsetPosition = offsetPosition;
    }

    createQuery(): Query<T2> {
        return new Query<T2>(this, this.dao, this.predicates, this.initialValues, this.limitPosition, this.offsetPosition);
    }
}