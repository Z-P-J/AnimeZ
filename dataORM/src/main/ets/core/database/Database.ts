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
import { DatabaseStatement } from './DatabaseStatement';
import { OnTableChangedListener } from '../dbflow/listener/OnTableChangedListener'
/**
 * Database abstraction used internally
 */
export interface Database {
    rawQuery(predicates: dataRdb.RdbPredicates, selectionArgs?: string[]): Promise<any>;

    rawQuerys(sql: string, selectionArgs?: Array<any>): Promise<any>;

    Delete(predicates: dataRdb.RdbPredicates): Promise<number>;

    execSQL(sql: string, bindArgs?: Array<any>);

    beginTransaction();

    endTransaction();

    rollBack();

    execSQL(sql: string, bindArgs: any[]);

    compileStatement(sql: dataRdb.RdbPredicates, tableName?: string): DatabaseStatement;

    getRawDatabase(): dataRdb.RdbStore;

    /**
     * 添加监听
     */
    addTableChangedListener(onTableChangedListener: OnTableChangedListener<any>);
    /**
      * 获取监听
      */
    getTableChangedListener(): OnTableChangedListener<any>
    /**
      * 移除监听
      */
    removeTableChangedListener();
}
