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
import { WhereCondition } from './WhereCondition'
import { StringCondition } from './StringCondition'
import { PropertyCondition } from './PropertyCondition'
import { Property } from '../Property'
import { StringBuilder } from '../StringBuilder'

export class Conditions {
    condition: WhereCondition;
    combineOp: string;
    cond1: WhereCondition;
    cond2: WhereCondition;
    conditions: Array<WhereCondition>;
}

/** Internal class to collect WHERE conditions. */
export class WhereCollector<T> {
    private dao: AbstractDao<T, any> ;
    private whereConditions: Array<WhereCondition>;
    private tablePrefix: string;
    private conditions: Array<Conditions>
    private predicates: dataRdb.RdbPredicates;

    constructor(dao: AbstractDao<T, any>, tablePrefix: string) {
        this.dao = dao;
        this.tablePrefix = tablePrefix;
        this.predicates = new dataRdb.RdbPredicates(dao.getTablename())
        this.whereConditions = new Array<WhereCondition>();
    }

    add(cond: WhereCondition, condMore?: Array<WhereCondition>) {
        this.whereConditions.push(cond);
        if (condMore != undefined) {
            for (let i = 0;i < condMore.length; i++) {
                this.checkCondition(condMore[i]);
                this.whereConditions.push(condMore[i]);
            }
        }
    }

    combineWhereCondition(combineOp: string, cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): WhereCondition {
        let builder = new StringBuilder("(");
        let combinedValues = new Array();

        this.addCondition(builder, combinedValues, cond1);
        builder.append(combineOp);
        this.addCondition(builder, combinedValues, cond2);
        condMore.forEach(cond => {
            builder.append(combineOp);
            this.addCondition(builder, combinedValues, cond);
        });

        builder.append(')');
        return new StringCondition(builder.toString(), combinedValues);
    }

    combineWhereConditions(combineOp: string, cond1: WhereCondition, cond2: WhereCondition,
                           condMore: Array<WhereCondition>): WhereCondition {
        let builder = new StringBuilder("(");
        let combinedValues = new Array<any>();
        if (combineOp === "OR") {
            this.predicates.beginWrap();
            this.whereCase(cond1);
            this.predicates.or()
            this.whereCase(cond2);
            for (let i = 0;i < condMore.length; i++) {
                this.predicates.or()
                this.whereCase(condMore[i]);
            }
            this.predicates.endWrap();
        } else if (combineOp === "AND") {
            this.whereCase(cond1);
            this.predicates.and()
            this.whereCase(cond2);
            for (let j = 0;j < condMore.length; j++) {
                this.predicates.and()
                this.whereCase(condMore[j]);
            }
        }
        this.addCondition(builder, combinedValues, cond1);
        builder.append(combineOp);
        this.addCondition(builder, combinedValues, cond2);

        for (let i = 0;i < condMore.length; i++) {
            builder.append(combineOp);
            this.addCondition(builder, combinedValues, condMore[i]);
        }
        builder.append(')');
        return new StringCondition(builder.toString(), null, combinedValues);
    }

    addCondition(builder: StringBuilder, values: Array<any>, condition: WhereCondition) {
        this.checkCondition(condition);
        condition.appendTo(builder, this.tablePrefix);
        condition.appendValuesTo(values);
    }

    checkCondition(whereCondition: WhereCondition) {
        if (whereCondition instanceof PropertyCondition) {
            this.checkProperty((whereCondition).property);
        }
    }

    public whereCase(whereCondition: WhereCondition) {
        if (whereCondition.constructor.name == "PropertyCondition") {
            let op: string = (<PropertyCondition> whereCondition).op;
            let property: Property = (<PropertyCondition> whereCondition).property;
            let value: any = (<PropertyCondition> whereCondition).value;
            let values: any[] = (<PropertyCondition> whereCondition).values;
            switch (op) {
                case "eq":
                    this.predicates.equalTo(property.columnName, value)
                    break;
                case "notEq":
                    this.predicates.notEqualTo(property.columnName, value)
                    break;
                case "like":
                    this.predicates.like(property.columnName, value)
                    break;
                case "between":
                    this.predicates.between(property.columnName, values[0], values[1])
                    break;
                case "in":
                    this.predicates.in(property.columnName, values)
                    break;
                case "notIn":
                    this.predicates.notIn(property.columnName, values)
                    break;
                case "gt":
                    this.predicates.greaterThan(property.columnName, value)
                    break;
                case "lt":
                    this.predicates.lessThan(property.columnName, value)
                    break;
                case "ge":
                    this.predicates.greaterThanOrEqualTo(property.columnName, value)
                    break;
                case "le":
                    this.predicates.lessThanOrEqualTo(property.columnName, value)
                    break;
                case "isNull":
                    this.predicates.isNull(property.columnName)
                    break;
                case "isNotNull":
                    this.predicates.isNotNull(property.columnName)
                    break;
            }
        }
    }

    checkProperty(property: Property) {
        if (this.dao != null) {
            let properties: Property[] = this.dao.getProperties();
            let found: boolean = false;
            properties.forEach(property2 => {
                if (property == property2) {
                    found = true;
                    return;
                }
            });
            if (!found) {
                throw new Error("Property '" + property.name + "' is not part of " + this.dao);
            }
        }
    }

    appendWhereClause() {
        for (let index = 0; index < this.whereConditions.length; index++) {
            this.whereCase(this.whereConditions[index])
            if (index != this.whereConditions.length - 1) {
                this.predicates.and()
            }
        }
    }

    appendWhereTerms(builder: StringBuilder, tablePrefixOrNull: string, values: Array<Object>) {
        for (let index = 0; index < this.whereConditions.length; index++) {
            let condition = this.whereConditions[index];
            condition.appendTo(builder, tablePrefixOrNull);
            condition.appendValuesTo(values);
            if (index != this.whereConditions.length - 1) {
                builder.append(" AND ");
            }
        }
    }

    isEmpty(): boolean {
        return (this.whereConditions == null || this.whereConditions.length == 0);
    }
}
