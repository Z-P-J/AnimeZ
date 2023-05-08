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
import { Database } from '../database/Database'
import { DatabaseStatement } from '../database/DatabaseStatement'
import { SqlUtils } from '../internal/SqlUtils'

export class TableStatements {
    private db: Database;
    private tablename: string;
    private allColumns: string[];
    private pkColumns: string[];
    private insertStatement: DatabaseStatement;
    private insertOrReplaceStatement: DatabaseStatement;
    private updateStatement: DatabaseStatement;
    private deleteStatement: DatabaseStatement;
    private countStatement: DatabaseStatement;
    private selectAll: string;
    private selectByKey: string;
    private selectByRowId: string;
    private selectKeys: string;
    protected rdb: dataRdb.RdbPredicates;

    public constructor(db: Database, tablename: string, allColumns: string[], pkColumns: string[]) {
        this.db = db;
        this.tablename = tablename;
        this.allColumns = allColumns;
        this.pkColumns = pkColumns;
    }

    public getInsertStatement(): DatabaseStatement {
        if (this.insertStatement == null) {
            this.rdb = new dataRdb.RdbPredicates(this.tablename);
            let newInsertStatement: DatabaseStatement = this.db.compileStatement(this.rdb, this.tablename);
            if (this.insertStatement == null) {
                this.insertStatement = newInsertStatement;
            }
        }
        return this.insertStatement;
    }

    public getInsertOrReplaceStatement(): DatabaseStatement {
        if (this.insertOrReplaceStatement == null) {
            this.rdb = new dataRdb.RdbPredicates(this.tablename);
            let newInsertOrReplaceStatement: DatabaseStatement = this.db.compileStatement(this.rdb, this.tablename);
            if (this.insertOrReplaceStatement == null) {
                this.insertOrReplaceStatement = newInsertOrReplaceStatement;
            }
        }
        return this.insertOrReplaceStatement;
    }

    public getDeleteStatement(): DatabaseStatement {
        if (this.deleteStatement == null) {
            this.rdb = new dataRdb.RdbPredicates(this.tablename);
            let newDeleteStatement: DatabaseStatement = this.db.compileStatement(this.rdb);
            if (this.deleteStatement == null) {
                this.deleteStatement = newDeleteStatement;
            }
        }
        return this.deleteStatement;
    }

    public getUpdateStatement(): DatabaseStatement{
        if (this.updateStatement == null) {
            this.rdb = new dataRdb.RdbPredicates(this.tablename)
            let newUpdateStatement: DatabaseStatement = this.db.compileStatement(this.rdb);
            if (this.updateStatement == null) {
                this.updateStatement = newUpdateStatement;
            }
            if (this.updateStatement != newUpdateStatement) {
                this.updateStatement = newUpdateStatement;
            }
        }
        return this.updateStatement;
    }

    public getCountStatement(): DatabaseStatement{
        this.rdb = new dataRdb.RdbPredicates(this.tablename);
        if (this.countStatement == null) {
            this.countStatement = this.db.compileStatement(this.rdb);
        }
        return this.countStatement;
    }

    /** ends with an space to simplify appending to this string. */
    public getSelectAll(): dataRdb.RdbPredicates {
        this.rdb = new dataRdb.RdbPredicates(this.tablename)
        return this.rdb;
    }

    /** ends with an space to simplify appending to this string. */
    public getSelectKeys(): string  {
        if (this.selectKeys == null) {
            this.selectKeys = SqlUtils.createSqlSelect(this.tablename, "T", this.pkColumns, false);
        }
        return this.selectKeys;
    }

    public getSelectByKey(): dataRdb.RdbPredicates {
        this.rdb = new dataRdb.RdbPredicates(this.tablename)
        return this.rdb;
    }

    public getSelectByRowId(): string {
        if (this.selectByRowId == null) {
            this.selectByRowId = this.getSelectAll() + "WHERE ROWID=?";
        }
        return this.selectByRowId;
    }
}
