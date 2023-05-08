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

export interface IdentityScope<K, T> {

  get(key: K): T;

  put(key: K, entity: T);

  getNoLock(key: K): T;

  putNoLock(key: K, entity: T);

  detach(key: K, entity: T): boolean;

  remove(key: K);

  clear();

  lock();

  unlock();

  reserveRoom(count: number);

}