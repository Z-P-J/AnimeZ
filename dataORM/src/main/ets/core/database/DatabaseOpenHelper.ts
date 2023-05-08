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
import { Database } from './Database';
import { SQLiteOpenHelper } from './SQLiteOpenHelper'
import { StandardDatabase } from './StandardDatabase'
import { Migration } from '../dbflow/Migration'
import { StorageUtils } from '../StorageUtils'

/**
 * SQLiteOpenHelper to allow working with dataORM's {@link Database} abstraction to create and update database schemas.
 */
export abstract class DatabaseOpenHelper extends SQLiteOpenHelper {
    private contexts: any
    private name: string
    private versions: number
    protected entities: any
    private migrations: Array<Migration>

    constructor(context: any, name: string, version: number, factory?: any, errorHandler?: any) {
        super(context, name, version, factory, errorHandler);
        this.contexts = context;
        this.name = name;
        this.versions = version;
    }

    setEntities(...entities: any[]) {
        this.entities = entities;
        //entities全局记录
        globalThis.entityClsArr = entities;
    }

    setMigration(...migration: Array<Migration>) {
        this.migrations = migration
    }

    getMigration(): Array<Migration>{
        return this.migrations;
    }

    async setVersion(version: number) {
        this.versions = await StorageUtils.getValueByKey("dbVersion", 1, this.contexts)
        let db = await this.getWritableDb();
        if (version != this.versions) {
            if (version > this.versions) {
                this.onUpgrade_D(db, version, this.versions)
            } else if (version < this.versions) {
                throw Error("The database version does not support rollback")
            }
            this.versions = version;
            StorageUtils.putValue("dbVersion", this.versions, this.contexts);
        }
    }


    /**
     * Like {@link #getWritableDatabase()}, but returns a dataORM abstraction of the database.
     * The backing DB is an standard {@link SQLiteDatabase}.
     */
    async getWritableDb(): Promise<Database> {
        return this.wrap(await this.getWritableDatabase());
    }

    /**
     * Like {@link #getReadableDatabase()}, but returns a dataORM abstraction of the database.
     * The backing DB is an standard {@link SQLiteDatabase}.
     */
    async getReadableDb(): Promise<Database> {
        return this.wrap(await this.getReadableDatabase());
    }

    wrap(sqLiteDatabase: dataRdb.RdbStore): Database{
        return new StandardDatabase(sqLiteDatabase);
    }

    /**
     * Delegates to {@link #onCreate(Database)}, which uses dataORM's database abstraction.
     */

    onCreate(db: dataRdb.RdbStore) {
        this.onCreate_D(this.wrap(db));
    }

    /**
     * Override this if you do not want to depend on {@link SQLiteDatabase}.
     */
    onCreate_D(db: Database) {
        //         Do nothing by default
    }

    /**
     * Delegates to {@link #onUpgrade(Database, int, int)}, which uses dataORM's database abstraction.
     */
    onUpgrade(db: dataRdb.RdbStore, oldVersion: number, newVersion: number) {
        this.onUpgrade_D(this.wrap(db), oldVersion, newVersion);
    }

    /**
     * Override this if you do not want to depend on {@link SQLiteDatabase}.
     */
    onUpgrade_D(db: Database, oldVersion: number, newVersion: number) {
        // Do nothing by default
    }

    /**
     * Delegates to {@link #onOpen(Database)}, which uses dataORM's database abstraction.
     */
    onOpen(db: dataRdb.RdbStore) {
        this.onOpen_D(this.wrap(db));
    }

    /**
     * Override this if you do not want to depend on {@link SQLiteDatabase}.
     */
    onOpen_D(db: Database) {
        // Do nothing by default
    }
}
