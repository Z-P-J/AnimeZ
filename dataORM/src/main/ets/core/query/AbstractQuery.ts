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
import { InternalQueryDaoAccess } from '../InternalQueryDaoAccess'

export abstract class AbstractQuery <T> {
    protected dao: AbstractDao<T, any>;
    protected daoAccess: InternalQueryDaoAccess<T>;
    protected predicates: dataRdb.RdbPredicates|string;
    protected parameters: string[];

    protected static toStringArray(values: any[]): string[] {
        let length = values.length;
        let strings: string[] = new Array();
        for (let i = 0; i < length; i++) {
            let object = values[i];
            if (object != null) {
                strings[i] = object.toString();
            } else {
                strings[i] = null;
            }
        }
        return strings;
    }

    protected constructor(dao: AbstractDao<T, any>, predicates: dataRdb.RdbPredicates|string, parameters: string[]) {
        this.dao = dao;
        this.daoAccess = new InternalQueryDaoAccess<T>(dao);
        this.predicates = predicates;
        this.parameters = parameters;
    }

    /**
     * Sets the parameter (0 based) using the position in which it was added during building the query.
     */
    public setParameter(index: number, parameter: any): AbstractQuery<T>{
        if (parameter != null) {
            this.parameters[index] = parameter.toString();
        } else {
            this.parameters[index] = null;
        }
        return this;
    }

    /**
     * @see #setParameter(int, Object)
     */
    public setParameterForDate(index: number, parameter: Date): AbstractQuery<T>{
        let converted: number = parameter != null ? parameter.getTime() : null;
        return this.setParameter(index, converted);
    }

    /**
     * @see #setParameter(int, Object)
     */
    public setParameterForBoolean(index: number, parameter: boolean): AbstractQuery<T> {
        let converted: number = parameter != null ? (parameter ? 1 : 0) : null;
        return this.setParameter(index, converted);
    }
}
