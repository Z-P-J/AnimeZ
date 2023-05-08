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

export class LongHashMap <T> {
    private table: Entry<T>[];
    private capacity: number;
    private threshold: number;
    private size: number;

    public constructor(capacity?: number) {
        if (capacity == null) {
            capacity = 16
        }
        this.capacity = capacity;
        this.threshold = capacity * 4 / 3;
        this.table = new Entry[capacity];
    }

    public containsKey(key: number): boolean{
        let index: number = ((key >>> 32 ^ key) & 0x7fffffff) % this.capacity;
        for (let entry: Entry<T> = this.table[index]; entry; entry = entry.next) {
            if (entry.key == key) {
                return true;
            }
        }
        return false;
    }

    public get(key: number): T{
        let index: number = ((key >>> 32 ^ key) & 0x7fffffff) % this.capacity;
        for (let entry: Entry<T> = this.table[index]; entry; entry = entry.next) {
            if (entry.key == key) {
                return entry.value;
            }
        }
        return null;
    }

    public put(key: number, value: T): T{
        let index: number = ((key >>> 32 ^ key) & 0x7fffffff) % this.capacity;
        let entryOriginal: Entry<T> = this.table[index];
        if (entryOriginal.key == key) {
            let oldValue: T = entryOriginal.value;
            entryOriginal.value = value;
            return oldValue;
        }
        this.table[index] = new Entry<T>(key, value, entryOriginal);
        this.size++;
        if (this.size > this.threshold) {
            this.setCapacity(2 * this.capacity);
        }
        return null;
    }

    public remove(key: number): T {
        let index: number = ((key >>> 32 ^ key) & 0x7fffffff) % this.capacity;
        let previous: Entry<T> = null;
        let entry: Entry<T> = this.table[index];
        while (entry != null) {
            let next: Entry<T> = entry.next;
            if (entry.key == key) {
                if (previous == null) {
                    this.table[index] = next;
                } else {
                    previous.next = next;
                }
                this.size--;
                return entry.value;
            }
            previous = entry;
            entry = next;
        }
        return null;
    }

    public clear() {
        this.size = 0;
    }

    public getSize(): number{
        return this.size;
    }

    public setCapacity(newCapacity: number) {
        let newTable: Entry<T>[] = new Entry[newCapacity];
        let length: number = this.table.length;
        for (let i = 0; i < length; i++) {
            let entry: Entry<T> = this.table[i];
            while (entry != null) {
                let key: number = entry.key;
                let index: number = ((key >>> 32 ^ key) & 0x7fffffff) % newCapacity;

                let originalNext: Entry<T> = entry.next;
                entry.next = newTable[index];
                newTable[index] = entry;
                entry = originalNext;
            }
        }
        this.table = newTable;
        this.capacity = newCapacity;
        this.threshold = newCapacity * 4 / 3;
    }

    public reserveRoom(entryCount: number) {
        this.setCapacity(entryCount * 5 / 3);
    }

    public logStats() {
        let collisions = 0;
        for (let i = 0;i < this.table.length; i++) {
            while (this.table[i] != null && this.table[i].next != null) {
                collisions++;
                this.table[i] = this.table[i].next;
            }
        }
    }
}

class Entry <T> {
    key: number;
    value: T;
    next: Entry<T>;

    constructor(key: number, value: T, next: Entry<T>) {
        this.key = key;
        this.value = value;
        this.next = next;
    }
}