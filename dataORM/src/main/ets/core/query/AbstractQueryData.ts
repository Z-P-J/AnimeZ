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
import { AbstractDao } from '../AbstractDao'

export abstract class AbstractQueryData <T, Q extends AbstractQuery<T>> {
    predicates: dataRdb.RdbPredicates|string;
    dao: AbstractDao<T, any>;
    public initialValues: string[] ;

    constructor(dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates|string, initialValues: string[]) {
        this.dao = dao;
        this.predicates = predicates;
        this.initialValues = initialValues;
    }

    /**
     * Note: all parameters are reset to their initial values specified in {@link QueryBuilder}.
     */
    forCurrentThread(): Q {

        let query: Q = null;
        if (query == null) {
            query = this.createQuery();
        }
        return query;
    }

    abstract createQuery(): Q;
}
