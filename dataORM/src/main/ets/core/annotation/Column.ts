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

export function Column(v: {columnName: string, types: string}): PropertyDecorator {
    return (target, primeryKey) => {
        Reflect.defineMetadata('Column', v.columnName, target, primeryKey);
        Reflect.defineMetadata('Type', v.types, target, primeryKey);
    };
}

export function Entity(v: string): ClassDecorator {
    return (target) => {
        Reflect.defineMetadata('Table', v, target);
    };
}