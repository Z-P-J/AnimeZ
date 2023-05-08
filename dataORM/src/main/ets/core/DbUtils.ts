/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
    *
  * http://www.apache.org/licenses/LICENSE-2.0
    *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

import { Database } from './database/Database'
import { Unit8ArrayUtils } from './Unit8ArrayUtils'

export class DbUtils {
    public static async readRawFile(resourceMgr: any, filename: string): Promise<Uint8Array> {
        let per: Promise<Uint8Array> = resourceMgr.getRawFile(filename);
        return per;
    }

    public static async rawFile2Str(resourceMgr: any, filename: string): Promise<string> {
        let result: string = '';
        let arr = await this.readRawFile(resourceMgr, filename);
        result = Unit8ArrayUtils.Uint8ArrayTostring(arr);
        return result;
    }

    public static async executeSqlStatements(db: Database, statements: string[]): Promise<number> {
        let count: number = 0;
        for (let line of statements) {
            line = line.trim();
            if (line.length > 0) {
                await db.execSQL(line);
                count++;
            }
        }
        return count;
    }

    public static async executeSqlStatementsInTx(db: Database, statements: string[]): Promise<number> {
        let e;
        try {
            db.beginTransaction();
            let count: number = await this.executeSqlStatements(db, statements);
            db.endTransaction();
            return count;
        } catch (err) {
            console.error('executeSqlStatementsInTx err:' + err.message + '----stack:' + err.stack)
            db.rollBack();
            e = err;
        }
        if (e) {
            throw e;
        }
    }

    public static async executeSqlScript(resourceMgr: any, db: Database, rawFilename: string): Promise<number> {
        return await this.executeSqlScriptTr(resourceMgr, db, rawFilename, true);
    }

    public static async executeSqlScriptTr(resourceMgr: any, db: Database, rawFilename: string, transactional: boolean): Promise<number> {
        let sql = await DbUtils.rawFile2Str(resourceMgr, rawFilename);
        let reg = / *; *\r*\n*\t* */gi;
        let lines: string[] = sql.split(reg);
        let count: number;
        if (transactional) {
            count = await this.executeSqlStatementsInTx(db, lines);
        } else {
            count = await this.executeSqlStatements(db, lines);
        }
        return count;
    }
}

