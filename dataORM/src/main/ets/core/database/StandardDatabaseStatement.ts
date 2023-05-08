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

import {SQLiteStatement} from './SQLiteStatement'
import {DatabaseStatement} from './DatabaseStatement';

export class StandardDatabaseStatement implements DatabaseStatement {
  delegate: SQLiteStatement;

  public constructor(delegate: SQLiteStatement) {
    this.delegate = delegate;
  }
  async executeDelete():Promise<number> {
    return await this.delegate.executeDelete();
  }
  async executeUpdate():Promise<number> {
    return this.delegate.executeUpdate();
  }
  executeInsert(): Promise<number> {
    return this.delegate.executeInsert();
  }
  bindValue(key:string,value:any){
    this.delegate.bindValue(key, value);
  }
  bindString(index: number, value: string) {
    this.delegate.bindString(index, value);
  }
  bindBlob(index: number, value: any) {
    this.delegate.bindBlob(index, value);
  }
  bindLong(index: number, value: number) {
    this.delegate.bindLong(index, value);
  }
  clearBindings() {
    this.delegate.clearBindings();
  }
  bindDouble(index: number, value: number) {
    this.delegate.bindDouble(index, value);
  }

  getRawStatement(): SQLiteStatement {
    return this.delegate;
  }
}
