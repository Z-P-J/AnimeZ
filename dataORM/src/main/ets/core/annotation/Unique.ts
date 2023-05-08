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
 * Marks property should have a UNIQUE constraint during table creation.
 * This annotation is also applicable with @ToOne without additional foreign key property
 *
 * <p>
 * To have a unique constraint after table creation you can use {@link Index#unique()}
 * </p>
 *
 * <p>
 * Note having both @Unique and {@link Index} is redundant and causes performance decrease
 * on DB level. See <a href="https://www.sqlite.org/lang_createtable.html">here</a> for more information.
 * </p>
 *
 * @see Index#unique()
 */
export function Unique(v: boolean = true) {
    return (target, primeryKey) => {
        Reflect.defineMetadata('Unique', v, target, primeryKey);
    };
}