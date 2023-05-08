/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *   http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

import dataRdb from '@ohos.data.relationalStore'
import { StandardDatabase } from './StandardDatabase'
import { TableAction } from '../dbflow/listener/TableAction'

export class SQLiteStatement {
    public sql: dataRdb.RdbPredicates;
    public bindArgs: any[];
    public tableName: string;
    private db: dataRdb.RdbStore;
    private standardDatabase: StandardDatabase;
    private valueBucket: { };

    constructor(sql: dataRdb.RdbPredicates, db?: dataRdb.RdbStore, tableName?: string) {
        this.sql = sql;
        if (tableName != undefined)
        this.tableName = tableName
        this.db = db;
    }

    setStandardDatabase(standardDatabase: StandardDatabase) {
        this.standardDatabase = standardDatabase;
    }

    async executeDelete(): Promise<number> {
        let listener = this.standardDatabase.getTableChangedListener();
        return this.db.delete(this.sql).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.DELETE);
            }
            return data;
        })
    }

    async executeUpdate(): Promise<number> {
        let entity = this.valueBucket;
        let listener = this.standardDatabase.getTableChangedListener();
        return this.db.update(entity, this.sql).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.UPDATE);
            }
            return data;
        })
    }

    async executeInsert(): Promise<number> {
        let listener = this.standardDatabase.getTableChangedListener();
        return this.db.insert(this.tableName, this.valueBucket).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.INSERT);
            }
            return data;
        })
    }

    simpleQueryForBlobFileDescriptor(): any {
        let t: any;
        return t;
    }
    bindValue(key: string, value: any) {
        this.valueBucket[key] = value;
    }
    bindLong(index: number, value: number) {
        this.bindArgs[index] = value;
    }

    bindDouble(index: number, value: number) {
        this.bindArgs[index] = value;
    }

    bindString(index: number, value: string) {
        this.bindArgs[index] = value;
    }

    bindBlob(index: number, value: any) {
        this.bindArgs[index] = value;
    }

    clearBindings() {
        this.bindArgs = [];
        this.valueBucket={};
    }
}
