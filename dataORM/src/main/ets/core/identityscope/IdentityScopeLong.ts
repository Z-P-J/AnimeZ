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

import {IdentityScope} from './IdentityScope'
import {LongHashMap} from '../internal/LongHashMap'

export class IdentityScopeLong <Number, T> implements IdentityScope<number, T> {
  private map: LongHashMap<T> ;

  public constructor() {
    this.map = new LongHashMap<T>();
  }

  public get(key: number): T{
    return this.get2(key);
  }

  public getNoLock(key: number): T{
    return this.get2NoLock(key);
  }

  public get2(key: number): T{
    let ref: T;
    ref = this.map.get(key);
    if (ref != null) {
      return ref;
    } else {
      return null;
    }
  }

  public get2NoLock(key: number): T{
    let ref: T = this.map.get(key);
    if (ref != null) {
      return ref;
    } else {
      return null;
    }
  }

  public put(key: number, entity: T) {
    this.put2(key, entity);
  }

  public putNoLock(key: number, entity: T) {
    this.put2NoLock(key, entity);
  }

  public put2(key: number, entity: T) {
    this.map.put(key, entity);
  }

  public put2NoLock(key: number, entity: T) {
    this.map.put(key, entity);
  }

  public detach(key: number, entity: T): boolean {
    if (this.get(key) == entity && entity != null) {
      this.remove(key);
      return true;
    } else {
      return false;
    }
  }

  public remove(key: number) {
    this.map.remove(key);
  }


  public clear() {
    this.map.clear();
  }

  public lock() {
  }

  public unlock() {
  }

  public reserveRoom(count: number) {
    this.map.reserveRoom(count);
  }
}
