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
import { AbstractQuery } from './AbstractQuery'
import { AbstractQueryData } from './AbstractQueryData'
import { AbstractDao } from '../AbstractDao'
import { Database } from '../database/Database';

export class DeleteQuery<T> extends AbstractQuery<T> {
    static create<T2>(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: Object[]): DeleteQuery<T2> {
        let queryData = new QueryData<T2>(dao, predicates, super.toStringArray(initialValues));
        return queryData.forCurrentThread();
    }

    private queryData: QueryData<T>;

    constructor(queryData: QueryData<T>, dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates|string, initialValues: string[]) {
        super(dao, predicates, initialValues);
        this.queryData = queryData;
    }

    public forCurrentThread(): DeleteQuery<T> {
        return this.queryData.forCurrentThread();
    }

    /**
     * Deletes all matching entities without detaching them from the identity scope (aka session/cache). Note that this
     * method may lead to stale entity objects in the session cache. Stale entities may be returned when loaded by
     * their
     * primary key, but not using queries.
     */
    public async executeDeleteWithoutDetachingEntities() {
        let db: Database = this.dao.getDatabase();

        // Do TX to acquire a connection before locking this to avoid deadlocks
        // Locking order as described in AbstractDao
        let err;
        db.beginTransaction();
        try {
            let id = await db.Delete(<dataRdb.RdbPredicates>this.predicates);
            db.endTransaction();
        } catch (e) {
            console.error("err_msg:" + e.message + "--err:" + e.stack)
            db.rollBack()
            err = e;
        }
        if (err) {
            throw err;
        }
    }

    // copy setParameter methods to allow easy chaining
    public setParameter(index: number, parameter: object): DeleteQuery<T> {
        return <DeleteQuery<T>> super.setParameter(index, parameter);
    }

    public setParameterForDate(index: number, parameter: Date): DeleteQuery<T> {
        return <DeleteQuery<T>> super.setParameterForDate(index, parameter);
    }

    public setParameterForBoolean(index: number, parameter: boolean): DeleteQuery<T> {
        return <DeleteQuery<T>> super.setParameterForBoolean(index, parameter);
    }
}

class QueryData<T2> extends AbstractQueryData<T2, DeleteQuery<T2>> {
    constructor(dao: AbstractDao<T2, any>, predicates: dataRdb.RdbPredicates | string, initialValues: string[]) {
        super(dao, predicates, initialValues);
    }

    createQuery(): DeleteQuery<T2> {
        return new DeleteQuery<T2>(this, this.dao, this.predicates, this.initialValues);
    }
}