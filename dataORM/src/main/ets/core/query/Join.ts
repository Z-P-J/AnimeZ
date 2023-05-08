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

import { AbstractDao } from '../AbstractDao'
import { Property } from '../Property'
import { WhereCollector } from './WhereCollector'
import { WhereCondition } from './WhereCondition'

/**
 * A Join lets you relate to other entity types for queries, and allows using WHERE statements on the joined entity
 * type.
 */
export class Join <SRC, DST> {
    sourceTablePrefix: string;
    daoDestination: AbstractDao<DST, any>;
    joinPropertySource: Property;
    joinPropertyDestination: Property;
    tablePrefix: string;
    whereCollector: WhereCollector<DST>;

    public constructor(sourceTablePrefix: string, sourceJoinProperty: Property,
                       daoDestination: AbstractDao<DST, any>, destinationJoinProperty: Property,
                       joinTablePrefix: string) {
        this.sourceTablePrefix = sourceTablePrefix;
        this.joinPropertySource = sourceJoinProperty;
        this.daoDestination = daoDestination;
        this.joinPropertyDestination = destinationJoinProperty;
        this.tablePrefix = joinTablePrefix;
        this.whereCollector = new WhereCollector<DST>(daoDestination, joinTablePrefix);
    }

    /**
       * Adds the given conditions to the where clause using an logical AND. To create new conditions, use the properties
       * given in the generated dao classes.
       */
    public where(cond: WhereCondition,condMore: Array<WhereCondition>): Join<SRC, DST>{
        this.whereCollector.add(cond, condMore);
        return this;
    }

    /**
       * Adds the given conditions to the where clause using an logical OR. To create new conditions, use the properties
       * given in the generated dao classes.
       */
    public whereOr(cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): Join<SRC, DST>{
        this.whereCollector.add(this.or(cond1, cond2, condMore));
        return this;
    }

    /**
       * Creates a WhereCondition by combining the given conditions using OR. The returned WhereCondition must be used
       * inside {@link #where(WhereCondition, WhereCondition...)} or
       * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
       */
    public or(cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): WhereCondition {
        return this.whereCollector.combineWhereConditions(" OR ", cond1, cond2, condMore);
    }

    /**
       * Creates a WhereCondition by combining the given conditions using AND. The returned WhereCondition must be used
       * inside {@link #where(WhereCondition, WhereCondition...)} or
       * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
       */
    public and(cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): WhereCondition{
        return this.whereCollector.combineWhereConditions(" AND ", cond1, cond2, condMore);
    }

    public getTablePrefix(): string {
        return this.tablePrefix;
    }

    /**
     * Adds the given conditions to the where clause using an logical AND. To create new conditions, use the properties
     * given in the generated dao classes.
     */
    public whereSql( cond: WhereCondition, condMore?: Array<WhereCondition>): Join<SRC, DST> {
        this.whereCollector.add(cond, condMore);
        return this;
    }
}
