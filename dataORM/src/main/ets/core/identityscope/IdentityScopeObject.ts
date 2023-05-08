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

import { IdentityScope } from './IdentityScope'

export class IdentityScopeObject <K, T> implements IdentityScope<K, T> {
    private map: Map<K, T>;

    public constructor() {
        this.map = new Map<K, T>();
    }

    public get(key: K): T{
        let ref: T;
        ref = this.map.get(key);
        if (ref != null) {
            return ref;
        } else {
            return null;
        }
    }

    public getNoLock(key: K): T{
        let ref: T = this.map.get(key);
        if (ref != null) {
            return ref;
        } else {
            return null;
        }
    }

    public put(key: K, entity: T) {
        this.map.set(key, entity);
    }

    public putNoLock(key: K, entity: T) {
        this.map.set(key, entity);
    }

    public detach(key: K, entity: T): boolean {
        if (this.get(key) == entity && entity != null) {
            this.remove(key);
            return true;
        } else {
            return false;
        }

    }

    public remove(key: K) {
        this.map.delete(key);
    }

    public clear() {
        this.map.clear();
    }

    public lock() {
    }

    public unlock() {
    }

    public reserveRoom(count: number) {
    }
}
