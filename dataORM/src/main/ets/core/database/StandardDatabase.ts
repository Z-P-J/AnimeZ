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

import  dataRdb  from '@ohos.data.relationalStore'
import { Database } from './Database'
import { DatabaseStatement } from './DatabaseStatement';
import { SQLiteStatement } from './SQLiteStatement';
import { StandardDatabaseStatement } from './StandardDatabaseStatement';
import { OnTableChangedListener } from '../dbflow/listener/OnTableChangedListener'
import { TableAction } from '../dbflow/listener/TableAction';

export class StandardDatabase implements Database {
    private delegate: dataRdb.RdbStore;
    protected myOnTableChangedListener = null;

    constructor(delegate: dataRdb.RdbStore) {
        this.delegate = delegate;
    }

    async rawQuery(predicates: dataRdb.RdbPredicates, selectionArgs: string[]): Promise<any> {
        let listener = this.myOnTableChangedListener;
        return this.delegate.query(predicates, selectionArgs).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.QUERY);
            }
            return data;
        })
    }

    async rawQuerys(sql: string, selectionArgs?: Array<any>): Promise<any> {
        let listener = this.myOnTableChangedListener;
        return this.delegate.querySql(sql, selectionArgs).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.QUERY);
            }
            return data;
        })
    }

    async Delete(predicates: dataRdb.RdbPredicates): Promise<any> {
        let listener = this.myOnTableChangedListener;
        return this.delegate.delete(predicates).then((data) => {
            if (listener != null) {
                listener.onTableChanged(data, TableAction.DELETE);
            }
            return data;
        })
    }

    beginTransaction() {
        this.delegate.beginTransaction()
    }

    endTransaction() {
        this.delegate.commit()
    }

    rollBack() {
        this.delegate.rollBack()
    }

    async execSQL(sql: string, bindArgs?: any[]) {
        let promise = this.delegate.executeSql(sql, bindArgs);
        await promise.then(async (data) => {
            console.info('StandardDatabase execSQL done.');
        })
    }

    compileStatement(sql: dataRdb.RdbPredicates, tableName?: string): DatabaseStatement {
        if (tableName != undefined) {
            let sQLiteStatement = new SQLiteStatement(sql, this.delegate, tableName);
            sQLiteStatement.setStandardDatabase(this);

            return new StandardDatabaseStatement(sQLiteStatement);
        }
        let sQLiteStatement = new SQLiteStatement(sql, this.delegate);
        sQLiteStatement.setStandardDatabase(this);
        return new StandardDatabaseStatement(sQLiteStatement);
    }

    getRawDatabase(): any {
        return this.delegate;
    }

    getSQLiteDatabase(): dataRdb.RdbStore {
        return this.delegate;
    }

    addTableChangedListener(onTableChangedListener: OnTableChangedListener<any>): void {
        this.myOnTableChangedListener = onTableChangedListener

    }

    getTableChangedListener(): OnTableChangedListener<any>{
        return this.myOnTableChangedListener
    }

    removeTableChangedListener() {
        this.myOnTableChangedListener = null

    }
}
