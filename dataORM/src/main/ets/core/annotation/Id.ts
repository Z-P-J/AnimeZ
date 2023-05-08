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

import 'reflect-metadata';

/**
 * Marks field is the primary key of the entity's table
 */
export function Id(v?: {
    isPrimaryKey?: boolean,
    autoincrement?: boolean
}) {
    return (target, primeryKey) => {
        if (v == undefined) {
            v = {
                isPrimaryKey: true,
                autoincrement: false
            }
        }
        if (v.isPrimaryKey == undefined) {
            v.isPrimaryKey = true
        }
        if (v.autoincrement == undefined) {
            v.autoincrement = false
        }
        Reflect.defineMetadata('isPrimaryKey', v.isPrimaryKey, target, primeryKey);
        Reflect.defineMetadata('autoincrement', v.autoincrement, target, primeryKey);
    };
}