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

type str = { string: string; }
type num = { number: number; }
type real = { number: number; }
type blob = { blob: blob; }

export class ColumnType {
    //实体类属性字段的数据库类型
    public static strType: str;
    public static numType: num;
    public static realType: real;
    public static blobType: blob;

    //实体类属性字段对应的数据库列类型（多在注解处使用）
    public static str: string = 'string';
    public static num: string = 'number';
    public static real: string = 'real';
    public static blob: string = 'blob';

    //数据库列类型值
    public static strValue: string = 'TEXT';
    public static numValue: string = 'INTEGER';
    public static realValue: string = 'REAL';
    public static blobValue: string = 'BLOB';
}
