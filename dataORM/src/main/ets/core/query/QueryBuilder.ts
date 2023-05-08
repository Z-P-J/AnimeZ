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
import { CursorQuery } from './CursorQuery'
import { DeleteQuery } from './DeleteQuery'
import { CountQuery } from './CountQuery'
import { Join } from './Join'
import { Query } from './Query'
import { PropertyCondition } from './PropertyCondition';
import dataRdb from '@ohos.data.relationalStore'
import { StringBuilder } from '../StringBuilder'
import { SqlUtils } from '../internal/SqlUtils'

export class QueryBuilder<T> {

    /** Set to true to debug the SQL. */
    public LOG_SQL: boolean;

    /** Set to see the given values. */
    public LOG_VALUES: boolean;
    private whereCollector: WhereCollector<T>;
    private orderBuilder: StringBuilder;
    private values: Array<any>;
    private joins: Array<Join<T, any>>;
    private dao: AbstractDao<T, any>;
    private tablePrefix: string;
    private limits: number;
    private offsets: number;
    private isDistinct: boolean;
    private predicates: dataRdb.RdbPredicates;
    /** stored with a leading space */
    private stringOrderCollations: string;

    /** For internal use by dataORM only. */
    public static internalCreate<T2>(dao: AbstractDao<T2, any>): QueryBuilder<T2> {
        return new QueryBuilder<T2>(dao);
    }

    protected constructor(dao: AbstractDao<T, any>, tablePrefix?: string) {
        this.dao = dao;
        this.predicates = new dataRdb.RdbPredicates(this.dao.getTablename())
        if (tablePrefix == null) {
            this.tablePrefix = "T";
        } else {
            this.tablePrefix = tablePrefix;
        }
        this.values = new Array<any>();
        this.joins = new Array<Join<T, any>>();
        this.whereCollector = new WhereCollector<T>(dao, this.tablePrefix);
        this.stringOrderCollations = " COLLATE NOCASE";
    }

    private checkOrderBuilder() {
        if (!!!this.orderBuilder) {
            this.orderBuilder = new StringBuilder('');
        } else if (this.orderBuilder.toString().length > 0) {
            this.orderBuilder.append(",");
        }
    }

    /** Use a SELECT DISTINCT to avoid duplicate entities returned, e.g. when doing joins. */
    public distinct(): QueryBuilder<T> {
        this.isDistinct = true;
        this.predicates.distinct()
        return this;
    }

    /**
     * If using embedded SQLite, this enables localized ordering of strings
     * (see {@link #orderAsc(Property...)} and {@link #orderDesc(Property...)}). This uses "COLLATE LOCALIZED", which
     * is unavailable in SQLCipher (in that case, the ordering is unchanged).
     *
     * @see #stringOrderCollation
     */
    public preferLocalizedStringOrder(): QueryBuilder<T> {
        this.stringOrderCollations = " COLLATE LOCALIZED";
        return this;
    }

    /**
     * Customizes the ordering of strings used by {@link #orderAsc(Property...)} and {@link #orderDesc(Property...)}.
     * Default is "COLLATE NOCASE".
     *
     * @see #preferLocalizedStringOrder
     */
    public stringOrderCollation(stringOrderCollation: string): QueryBuilder<T> {
        this.stringOrderCollations = stringOrderCollation == null || stringOrderCollation.startsWith(" ") ?
            stringOrderCollation : " " + stringOrderCollation;
        return this;
    }

    /**
     * Adds the given conditions to the where clause using an logical AND. To create new conditions, use the properties
     * given in the generated dao classes.
     */
    public where(cond: WhereCondition, condMore?: Array<WhereCondition>): QueryBuilder<T> {
        this.appendWhereClause(cond, condMore)
        return this;
    }

    public whereSql(cond: WhereCondition, condMore?: Array<WhereCondition>): QueryBuilder<T> {
        this.whereCollector.add(cond, condMore)
        return this;
    }

    public appendWhereClause(cond: WhereCondition, condMore?: WhereCondition[]) {
        this.whereCase(cond);
        if (condMore != undefined) {
            for (let index = 0; index < condMore.length; index++) {
                this.predicates.and()
                this.whereCase(condMore[index]);
            }
        }
    }

    /**
     * Adds the given conditions to the where clause using an logical OR. To create new conditions, use the properties
     * given in the generated dao classes.
     */
    public whereOr(cond1: WhereCondition, cond2: WhereCondition, ...condMore: Array<WhereCondition>): QueryBuilder<T> {
        this.or(cond1, cond2, condMore)
        return this;
    }

    /**
     * Creates a WhereCondition by combining the given conditions using OR. The returned WhereCondition must be used
     * inside {@link #where(WhereCondition, WhereCondition...)} or
     * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
     */
    public or(cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): WhereCondition {
        this.predicates.beginWrap();
        this.whereCase(cond1);
        this.predicates.or()
        this.whereCase(cond2);
        for (let i = 0;i < condMore.length; i++) {
            this.predicates.or()
            this.whereCase(condMore[i]);
        }
        this.predicates.endWrap();
        return this.whereCollector.combineWhereConditions("OR", cond1, cond2, condMore);
    }

    /**
     * Creates a WhereCondition by combining the given conditions using AND. The returned WhereCondition must be used
     * inside {@link #where(WhereCondition, WhereCondition...)} or
     * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
     */
    public and(cond1: WhereCondition, cond2: WhereCondition, condMore: Array<WhereCondition>): WhereCondition {
        this.whereCase(cond1);
        this.predicates.and()
        this.whereCase(cond2);
        for (let i = 0;i < condMore.length; i++) {
            this.predicates.and()
            this.whereCase(condMore[i]);
        }
        return this.whereCollector.combineWhereConditions("AND", cond1, cond2, condMore);
    }

    /**
     * Creates a WhereCondition by combining the given conditions using OR. The returned WhereCondition must be used
     * inside {@link #where(WhereCondition, WhereCondition...)} or
     * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
     */
    public sqlOr(cond1: WhereCondition, cond2: WhereCondition, ...condMore: WhereCondition[]): WhereCondition {
        return this.whereCollector.combineWhereCondition(" OR ", cond1, cond2, condMore);
    }

    /**
     * Creates a WhereCondition by combining the given conditions using AND. The returned WhereCondition must be used
     * inside {@link #where(WhereCondition, WhereCondition...)} or
     * {@link #whereOr(WhereCondition, WhereCondition, WhereCondition...)}.
     */
    public sqlAnd(cond1: WhereCondition, cond2: WhereCondition, ...condMore: WhereCondition[]): WhereCondition {
        return this.whereCollector.combineWhereCondition(" AND ", cond1, cond2, condMore);
    }

    /**
     * Expands the query to another entity type by using a JOIN. The primary key property of the primary entity for
     * this QueryBuilder is used to match the given destinationProperty.
     */
    public join<J>(destinationEntityClass: any, destinationProperty: Property): Join<T, J> {
        return this.join2(this.dao.getPkProperty(), destinationEntityClass, destinationProperty);
    }


    /**
     * Expands the query to another entity type by using a JOIN. The given sourceProperty is used to match the primary
     * key property of the given destinationEntity.
     */
    public join1<J>(sourceProperty: Property, destinationEntityClass: any): Join<T, J> {
        let destinationDao = this.dao.getSession().getDao(destinationEntityClass);
        let destinationProperty = destinationDao.getPkProperty();
        return this.addJoin(this.tablePrefix, sourceProperty, destinationDao, destinationProperty);
    }

    /**
     * Expands the query to another entity type by using a JOIN. The given sourceProperty is used to match the given
     * destinationProperty of the given destinationEntity.
     */
    public join2<J>(sourceProperty: Property, destinationEntityClass: any, destinationProperty: Property): Join<T, J> {
        let destinationDao = this.dao.getSession().getDao(destinationEntityClass);
        return this.addJoin(this.tablePrefix, sourceProperty, destinationDao, destinationProperty);
    }

    /**
     * Expands the query to another entity type by using a JOIN. The given sourceJoin's property is used to match the
     * given destinationProperty of the given destinationEntity. Note that destination entity of the given join is used
     * as the source for the new join to add. In this way, it is possible to compose complex "join of joins" across
     * several entities if required.
     */
    public join4<J>(sourceJoin: Join<any, T>, sourceProperty: Property, destinationEntityClass: any,
                    destinationProperty: Property): Join<T, J> {
        let destinationDao = this.dao.getSession().getDao(destinationEntityClass);
        return this.addJoin(sourceJoin.tablePrefix, sourceProperty, destinationDao, destinationProperty);
    }

    private addJoin<J>(sourceTablePrefix: string, sourceProperty: Property, destinationDao: AbstractDao<J, any>, destinationProperty: Property): Join<T, J> {
        let joinTablePrefix = "J" + (this.joins.length + 1);
        let join = new Join<T, J>(sourceTablePrefix, sourceProperty, destinationDao, destinationProperty, joinTablePrefix);
        this.joins.push(join);
        return join;
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

    /** Adds the given properties to the ORDER BY section using ascending order. */
    public orderAsc(properties: Property): QueryBuilder<T> {
        this.predicates.orderByAsc(properties.columnName)
        return this;
    }

    /** Adds the given properties to the ORDER BY section using descending order. */
    public orderDesc(properties: Property): QueryBuilder<T> {
        this.predicates.orderByDesc(properties.columnName)
        return this;
    }

    public orderAscSql(properties: Property): QueryBuilder<T> {
        this.orderAscOrDesc(" ASC", properties);
        return this;
    }

    public orderDescSql(properties: Property): QueryBuilder<T> {
        this.orderAscOrDesc(" DESC", properties);
        return this;
    }

    private orderAscOrDesc(ascOrDescWithLeadingSpace: string, ...properties: Property[]) {
        properties.forEach(property => {
            this.checkOrderBuilder();
            this.append(this.orderBuilder, property);
            if (this.stringOrderCollations != null) {
                this.orderBuilder.append(this.stringOrderCollations);
            }
            this.orderBuilder.append(ascOrDescWithLeadingSpace);
        });
    }
    /** Adds the given properties to the ORDER BY section using the given custom order. */
    public orderCustom(property: Property, customOrderForProperty: string): QueryBuilder<T> {
        this.checkOrderBuilder();
        this.append(this.orderBuilder, property).append(' ');
        this.orderBuilder.append(customOrderForProperty);
        return this;
    }

    protected append(builder: StringBuilder, property: Property): StringBuilder {
        this.whereCollector.checkProperty(property);
        builder.append(this.tablePrefix).append('.').append('\'').append(property.columnName).append('\'');
        return builder;
    }
    /** Limits the number of results returned by queries. */
    public limit(limit: number): QueryBuilder<T> {
        this.limits = limit;
        this.predicates.limitAs(limit)
        return this;
    }
    /**
     * Adds the given raw SQL string to the ORDER BY section. Do not use this for standard properties: orderAsc and
     * orderDesc are preferred.
     */
    public orderRaw(rawOrder: string): QueryBuilder<T> {
        this.checkOrderBuilder();
        this.orderBuilder.append(rawOrder);
        return this;
    }
    /**
     * Sets the offset for query results in combination with {@link #limit(int)}. The first {@code offset} results are
     * skipped and the total number of results will be limited by {@code limit}. You cannot use offset without limit.
     */
    public offset(offset: number): QueryBuilder<T> {
        this.offsets = offset;
        this.predicates.offsetAs(offset)
        return this;
    }

    /**
     * Builds a reusable query object (Query objects can be executed more efficiently than creating a QueryBuilder for
     * each execution.
     */
    public build(): Query<T> {

        this.createSelectBuilder();
        let limitPosition: number = this.checkAddLimit();
        let offsetPosition: number = this.checkAddOffset();

        return Query.create(this.dao, this.predicates, this.values, limitPosition, offsetPosition);
    }

    public buildSql(): Query<T> {

        let builder = new StringBuilder(this.createSelectSql())
        let limitPosition: number = this.checkAddLimitSql(builder);
        let offsetPosition: number = this.checkAddOffsetSql(builder);

        this.checkLog(builder.toString());
        return Query.create(this.dao, builder.toString(), this.values, limitPosition, offsetPosition);
    }

    /**
     * Builds a reusable query object for low level database.Cursor access.
     * (Query objects can be executed more efficiently than creating a QueryBuilder for each execution.
     */
    public buildCursor(): CursorQuery<T> {
        this.createSelectBuilder();
        let limitPosition: number = this.checkAddLimit();
        let offsetPosition: number = this.checkAddOffset();

        return CursorQuery.create(this.dao, this.predicates, this.values, limitPosition, offsetPosition);
    }

    public buildCursorSql(): CursorQuery<T> {
        let builder = new StringBuilder(this.createSelectSql())
        let limitPosition: number = this.checkAddLimitSql(builder);
        let offsetPosition: number = this.checkAddOffsetSql(builder);

        return CursorQuery.create(this.dao, builder.toString(), this.values, limitPosition, offsetPosition);
    }

    private createSelectBuilder() {
        this.appendJoinsAndWheres();
    }

    private createSelectSql(): string {
        let select = SqlUtils.createSqlSelect(this.dao.getTablename(), this.tablePrefix, this.dao.getAllColumns(), this.isDistinct);
        let builder = new StringBuilder(select);
        this.appendJoinAndWheres(builder, this.tablePrefix);
        if (this.orderBuilder != null && this.orderBuilder.toString().length > 0) {
            builder.append(" ORDER BY ").append(this.orderBuilder.toString());
        }
        return builder.toString();
    }

    private checkAddLimit(): number {
        let limitPosition = -1;
        if (this.limits != null) {
            this.predicates.limitAs(this.limits)
            this.values.push(this.limits);
            limitPosition = this.values.length - 1;
        }
        return limitPosition;
    }

    private checkAddLimitSql(builder: StringBuilder): number {
        let limitPosition = -1;
        if (this.limits != null) {
            builder.append(" LIMIT ?");
            this.values.push(this.limits);
            limitPosition = this.values.length - 1;
        }
        return limitPosition;
    }

    private checkAddOffset(): number {
        let offsetPosition = -1;
        if (this.offsets != null) {
            if (this.limits == null) {
                throw new Error("Offset cannot be set without limit");
            }
            this.predicates.limitAs(this.offsets)
            this.values.push(this.offsets);
            offsetPosition = this.values.length - 1;
        }
        return offsetPosition;
    }

    private checkAddOffsetSql(builder: StringBuilder): number {
        let offsetPosition = -1;
        if (this.offsets != null) {
            if (this.limits == null) {
                throw new Error("Offset cannot be set without limit");
            }
            builder.append(" OFFSET ?");
            this.values.push(this.offsets);
            offsetPosition = this.values.length - 1;
        }
        return offsetPosition;
    }
    /**
     * Builds a reusable query object for deletion (Query objects can be executed more efficiently than creating a
     * QueryBuilder for each execution.
     */
    public buildDelete(): DeleteQuery<T> {
        return DeleteQuery.create(this.dao, this.predicates, this.values);
    }

    public buildDeleteSql(): DeleteQuery<T> {
        if (this.joins.length == 0) {
            throw new Error("JOINs are not supported for DELETE queries");
        }
        let tablename = this.dao.getTablename();
        let baseSql = SqlUtils.createSqlDelete(tablename, null);
        let builder = new StringBuilder(baseSql);

        // tablePrefix gets replaced by table name below. Don't use tableName here because it causes trouble when
        // table name ends with tablePrefix.
        this.appendJoinAndWheres(builder, this.tablePrefix);

        let sql = builder.toString();
        // Remove table aliases, not supported for DELETE queries.
        // TODO(?): don't create table aliases in the first place.
        sql = sql.replace(this.tablePrefix + ".\"", '"' + tablename + "\".\"");
        this.checkLog(sql);

        return DeleteQuery.create(this.dao, sql, this.values);
    }
    /**
     * Builds a reusable query object for counting rows (Query objects can be executed more efficiently than creating a
     * QueryBuilder for each execution.
     */
    public buildCount(): CountQuery<T> {
        this.appendJoinsAndWheres();
        return CountQuery.create(this.dao, this.predicates, this.values);
    }

    public buildCountSql(): CountQuery<T> {
        let tablename = this.dao.getTablename();
        let baseSql = SqlUtils.createSqlSelectCountStar(tablename, this.tablePrefix);
        let builder = new StringBuilder(baseSql);
        this.appendJoinAndWheres(builder, this.tablePrefix);

        let sql = builder.toString();

        this.checkLog(sql);

        return CountQuery.create(this.dao, sql, this.values);
    }

    private checkLog(sql: string) {
        if (this.LOG_SQL) {
            console.debug("Built SQL for query: " + sql);
        }
        if (this.LOG_VALUES) {
            console.debug("Values for query: " + this.values);
        }
    }

    private appendJoinAndWheres(builder: StringBuilder, tablePrefixOrNull: string) {
        this.values = [];

        for (let i = 0;i < this.joins.length; i++) {
            let join = this.joins[i]
            builder.append(" JOIN ");
            builder.append('"').append(join.daoDestination.getTablename()).append('"').append(' ');
            builder.append(join.tablePrefix).append(" ON ");
            let t1 = SqlUtils.appendProperty("", join.sourceTablePrefix, join.joinPropertySource).concat('=');
            builder.append(t1);
            let t2 = SqlUtils.appendProperty("", join.tablePrefix, join.joinPropertyDestination);
            builder.append(t2);

        }
        let whereAppended = !this.whereCollector.isEmpty();
        if (whereAppended) {
            builder.append(" WHERE ");
            this.whereCollector.appendWhereTerms(builder, tablePrefixOrNull, this.values);
        }
        for (let i = 0;i < this.joins.length; i++) {
            let join = this.joins[i]
            if (!join.whereCollector.isEmpty()) {
                if (!whereAppended) {
                    builder.append(" WHERE ");
                    whereAppended = true;
                } else {
                    builder.append(" AND ");
                }
                join.whereCollector.appendWhereTerms(builder, join.tablePrefix, this.values);
            }
        }
    }

    private appendJoinsAndWheres() {

        let whereAppended: boolean = this.whereCollector != null;
        if (whereAppended) {
            this.whereCollector.appendWhereClause();
        }
        for (let i = 0;i < this.joins.length; i++) {
            if (this.joins[i].whereCollector != null) {
                this.joins[i].whereCollector.appendWhereClause();
            }
        }
    }

    /**
     * Shorthand for {@link QueryBuilder#build() build()}.{@link Query#list() list()}; see {@link Query#list()} for
     * details. To execute a query more than once, you should build the query and keep the {@link Query} object for
     * efficiency reasons.
     */
    public async list(): Promise<Array<T>> {
        return await this.build().list();
    }

    public async listSql(): Promise<Array<T>> {
        return await this.build().listSql();
    }
    /**
     * Shorthand for {@link QueryBuilder#build() build()}.{@link Query#unique() unique()}; see {@link Query#unique()}
     * for details. To execute a query more than once, you should build the query and keep the {@link Query} object for
     * efficiency reasons.
     */
    public unique(): T {
        return this.build().unique();
    }

    /**
     * Shorthand for {@link QueryBuilder#build() build()}.{@link Query#uniqueOrThrow() uniqueOrThrow()}; see
     * {@link Query#uniqueOrThrow()} for details. To execute a query more than once, you should build the query and
     * keep
     * the {@link Query} object for efficiency reasons.
     */
    public uniqueOrThrow(): T {
        return this.build().uniqueOrThrow();
    }

    /**
     * Shorthand for {@link QueryBuilder#buildCount() buildCount()}.{@link CountQuery#count() count()}; see
     * {@link CountQuery#count()} for details. To execute a query more than once, you should build the query and keep
     * the {@link CountQuery} object for efficiency reasons.
     */
    public async count(): Promise<number> {
        return await this.buildCount().count();
    }
}
