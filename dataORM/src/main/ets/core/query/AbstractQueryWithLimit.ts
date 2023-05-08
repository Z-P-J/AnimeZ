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

export abstract class AbstractQueryWithLimit <T> extends AbstractQuery<T> {
    protected limitPosition: number;
    protected offsetPosition: number;

    protected constructor(dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates|string, initialValues: string[], limitPosition: number,
                          offsetPosition: number) {
        super(dao, predicates, initialValues);
        this.limitPosition = limitPosition;
        this.offsetPosition = offsetPosition;
    }

    /**
       * Sets the parameter (0 based) using the position in which it was added during building the query. Note: all
       * standard WHERE parameters come first. After that come the WHERE parameters of joins (if any).
       */
    public setParameter(index: number, parameter: any): AbstractQueryWithLimit<T>{
        if (index >= 0 && (index == this.limitPosition || index == this.offsetPosition)) {
            throw new Error("Illegal parameter index: " + index);
        }
        return <AbstractQueryWithLimit<T>> super.setParameter(index, parameter);
    }

    /**
       * Sets the limit of the maximum number of results returned by this Query
       */
    public setLimit(limit: number) {
        if (this.limitPosition == -1) {
            throw new Error("Limit must be set with QueryBuilder before it can be used here");
        }
        this.parameters[this.limitPosition] = limit.toString();
    }

    /**
       * Sets the offset for results returned by this Query.
       */
    public setOffset(offset: number) {
        if (this.offsetPosition == -1) {
            throw new Error("Offset must be set with QueryBuilder before it can be used here");
        }
        this.parameters[this.offsetPosition] = offset.toString();
    }
}
