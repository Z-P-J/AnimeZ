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
 * Specifies that property is not null
 * <p>
 * You can also use any another NotNull or NonNull annotation (from any library or your own),
 * they are equal to using this
 * </p>
 */
export function NotNull(v: boolean = true) {
    return (target, primeryKey) => {
        Reflect.defineMetadata('NotNull', v, target, primeryKey);
    };
}