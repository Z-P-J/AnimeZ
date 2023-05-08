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

import dataRdb from '@ohos.data.relationalStore'

export class Migration {
    //数据库名称
    private dbName: string = "";
    //数据库表名
    private tableName: string = "";
    //数据库版本(默认为1)
    private dbVersion: number = 1;
    //对表进行修改的Alter语句(ALTER TABLE 语句用于在已有的表中添加、修改或删除列。)
    private alters: string = "";
    /**
     * dbName:数据库名称
     * table:表名称
     * dbVersion:数据库版本
     * */
    public constructor(dbName: string, tableName: string, dbVersion: number) {
        this.tableName = tableName;
        this.dbName = dbName;
        this.dbVersion = dbVersion;
    }
    //新增列操作(需要新增的列名以及列数据类型名称,返回当前类实例)
    addColumn(columnName: string, columnType: string): any {
        if (this.alters == "") {
            this.alters = "ALTER TABLE " + this.tableName + " ADD " + columnName + " " + columnType;
        }
        return this;
    }
    //删除列操作(需要删除的列名,返回当前类实例)
    deleteColumn(columnName: string): any {
        if (this.alters == "") {
            this.alters = "ALTER TABLE " + this.tableName + " DROP COLUMN " + columnName;
        }
        return this;
    }
    //对库进行备份
    /*
     * name:数据库名称
     **/
    static backupDB(dbName: string, backupDbName: string, dbVersion: number, context: any,encrypt:boolean) {
        dataRdb.getRdbStore(context, {
            name: dbName,
            securityLevel: dataRdb.SecurityLevel.S1,
            encrypt:encrypt
        }, function (err, rdbStore) {

            if (err) {
                console.error('test i Backup failed ,getRdbStore err: ' + err.message)
                return;
            }

            dataRdb.deleteRdbStore(context, backupDbName, function (err) {
                if (err) {
                    console.error("test i Delete RdbStore failed, err: " + err)
                    return
                }
                console.log("test i Delete RdbStore successfully.")

                let promiseBackup = rdbStore.backup(backupDbName)
                promiseBackup.then(() => {
                    console.info('test i Backup success.')
                }).catch((err) => {
                    console.error('test i Backup failed, err: ' + err)
                })
            })
        })
    }
    //修改列操作(需要修改的列名以及列数据类型名称,返回当前类实例)
    updateColumn(columnName: string, columnType: string): any {
        if (this.alters == "") {
            this.alters = "ALTER TABLE " + this.tableName + " ALTER COLUMN " + columnName + " " + columnType;
        }
        return this;
    }
    //列操作(需要将具体的列操作以SQL语句的方式传入并执行,具体规范参考 SQLite中 ALTER TABLE 语句)
    Alter(alters: string): any {
        if (this.alters != "") {
            this.alters = ""
        }
        this.alters = alters;
        return this;
    }
    //执行列操作并升级数据库
    public execute(context: any,encrypt:boolean): any {
        let that = this
        dataRdb.getRdbStore(context, {
            name: that.dbName,
            securityLevel: dataRdb.SecurityLevel.S1,
            encrypt:encrypt
        }, function (err, rdbStore) {
            if (err) {
                console.error('Migration：err==' + err)
            } else {
                rdbStore.executeSql(that.alters, null, function () {
                    console.log('Migration: done.')
                })
            }
        })

        return this;
    }
}