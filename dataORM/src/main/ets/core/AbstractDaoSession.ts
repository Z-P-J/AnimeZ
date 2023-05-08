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

import { Database } from './database/Database';
import { QueryBuilder } from './query/QueryBuilder';
import { AbstractDao } from './AbstractDao';
import { DaoException } from './DaoException';
import { JMap as Map } from './common/JMap';

/**
 * DaoSession gives you access to your DAOs, offers convenient persistence methods, and also serves as a session cache.<br>
 * <br>
 * To access the DAOs, call the get{entity}Dao methods by the generated DaoSession sub class.<br>
 * <br>
 * DaoSession offers many of the available persistence operations on entities as a convenience. Consider using DAOs
 * directly to access all available operations, especially if you call a lot of operations on a single entity type to
 * avoid the overhead imposed by DaoSession (the overhead is small, but it may add up).<br>
 * <br>
 * By default, the DaoSession has a session cache (IdentityScopeType.Session). The session cache is not just a plain
 * data cache to improve performance, but also manages object identities. For example, if you load the same entity twice
 * in a query, you will get a single Java object instead of two when using a session cache. This is particular useful
 * for relations pointing to a common set of entities.
 * 
 * This class is thread-safe.
 * 
 * @author Markus
 * 
 */
export class AbstractDaoSession {
    private db: Database;
    private entityToDao: Map<string, AbstractDao<any, any>>;

    constructor(db: Database) {
        this.db = db;
        this.entityToDao = new Map<string, AbstractDao<any, any>>();
    }

    protected registerDao<T>(entityClass: string, dao: AbstractDao<T, any>): void {
        this.entityToDao.put(entityClass, dao);
    }

    /** Convenient call for {@link AbstractDao#insert(Object)}. */
    public async insert<T>(entity: T): Promise<number> {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entity.constructor.name);
        return await dao.insert(entity);
    }

    /** Convenient call for {@link AbstractDao#insertOrReplace(Object)}. */
    public async insertOrReplace<T>(entity: T): Promise<number> {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entity.constructor.name);
        return await dao.insertOrReplace(entity);
    }

    /** Convenient call for {@link AbstractDao#refresh(Object)}. */
    public refresh<T>(entity: T): void {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entity.constructor.name);
        dao.refresh(entity);
    }

    /** Convenient call for {@link AbstractDao#update(Object)}. */
    public update<T>(entity: T): void {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entity.constructor.name);
        dao.update(entity);
    }

    /** Convenient call for {@link AbstractDao#delete(Object)}. */
    public delete<T>(entity: T): void {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entity.constructor.name);
        dao.delete(entity);
    }

    /** Convenient call for {@link AbstractDao#deleteAll()}. */
    public deleteAll<T>(entityClass: T): void {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entityClass.constructor.name);
        dao.deleteAll();
    }

    /** Convenient call for {@link AbstractDao#load(Object)}. */
    public async load<T, K>(entityClass: T, key: K): Promise<T> {
        let dao: AbstractDao<T, K> = <AbstractDao<T, K>> this.getDao(entityClass.constructor.name);
        return await dao.load(key);
    }

    /** Convenient call for {@link AbstractDao#loadAll()}. */
    public async loadAll<T, K>(entityClass: T): Promise<Array<T>> {
        let dao: AbstractDao<T, K> = <AbstractDao<T, K>> this.getDao(entityClass.constructor.name);
        return await dao.loadAll();
    }

    /** Convenient call for {@link AbstractDao#queryRaw(string, string...)}. */
    public async queryRaw<T, K>(entityClass: T, where: string, ...selectionArgs: string[]): Promise<Array<T>> {
        let dao: AbstractDao<T, K> = <AbstractDao<T, K>> this.getDao(entityClass.constructor.name);
        return await dao.queryRaw(where, ...selectionArgs);
    }

    /** Convenient call for {@link AbstractDao#queryBuilder()}. */
    public queryBuilder<T>(entityClass: T): QueryBuilder<T> {
        let dao: AbstractDao<T, any> = <AbstractDao<T, any>> this.getDao(entityClass.constructor.name);
        return dao.queryBuilder();
    }

    public getDao(entityClass: string): AbstractDao<any, any> {
        let dao: AbstractDao<any, any> = this.entityToDao.get(entityClass);
        if (dao == null) {
            throw new DaoException("No DAO registered for " + entityClass);
        }
        return dao;
    }

    /** Gets the Database for custom database access. Not needed for dataORM entities. */
    public getDatabase(): Database {
        return this.db;
    }
}
