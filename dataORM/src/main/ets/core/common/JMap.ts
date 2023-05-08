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

/*
 * MAP对象，实现MAP功能
 *
 * 接口：
 * size()     获取MAP元素个数
 * isEmpty()    判断MAP是否为空
 * clear()     删除MAP所有元素
 * put(key, value)   向MAP中增加元素（key, value)
 * remove(key)    删除指定KEY的元素，成功返回True，失败返回False
 * get(key)    获取指定KEY的元素值VALUE，失败返回NULL
 * element(index)   获取指定索引的元素（使用element.key，element.value获取KEY和VALUE），失败返回NULL
 * containsKey(key)  判断MAP中是否含有指定KEY的元素
 * containsValue(value) 判断MAP中是否含有指定VALUE的元素
 * values()    获取MAP中所有VALUE的数组（ARRAY）
 * keys()     获取MAP中所有KEY的数组（ARRAY）
 *
 * 例子：
 * var map = new Map(string,string);
 *
 * map.put("key", "value");
 * var val = map.get("key")
 * ……
 *
 */
class Node <T1, T2> {
    constructor(_key: T1, _value: T2) {
        this.key = _key
        this.value = _value
    }

    key: T1
    value: T2
}

export class JMap <T1, T2> {
    constructor() {
        this.elements = new Array();
    }

    elements: Array<Node<T1, T2>>

    //获取MAP元素个数
    size(): number {
        return this.elements.length;
    };

    //判断MAP是否为空
    isEmpty(): boolean {
        return (this.elements.length < 1);
    }

    //删除MAP所有元素
    clear(): void {
        this.elements = new Array();
    }
    //向MAP中增加元素（key, value)
    put(_key: T1, _value: T2): void {
        this.elements.push(new Node<T1, T2>(_key, _value));
    }
    //获取指定KEY的元素值VALUE，失败返回NULL
    get(_key: T1): T2 {
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].key == _key) {
                return this.elements[i].value;
            }
        }

        return null;
    }

    //获取指定索引的元素（使用element.key，element.value获取KEY和VALUE），失败返回NULL
    element(_index: number): Node<T1, T2> {
        if (_index < 0 || _index >= this.elements.length) {
            return null;
        }
        return this.elements[_index];
    };
    //删除指定KEY的元素，成功返回True，失败返回False
    removeByKey(_key: T1): boolean {
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].key == _key) {
                this.elements.splice(i, 1);
                return true;
            }
        }
        return bln;
    };

    //删除指定VALUE的元素，成功返回True，失败返回False
    removeByValue(_value: T2): boolean { //removeByValueAndKey
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].value == _value) {
                this.elements.splice(i, 1);
                return true;
            }
        }
        return bln;
    };

    //删除指定VALUE的元素，成功返回True，失败返回False
    removeByValueAndKey(_key: T1, _value: T2): boolean {
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].value == _value && this.elements[i].key == _key) {
                this.elements.splice(i, 1);
                return true;
            }
        }
        return bln;
    };


    //判断MAP中是否含有指定KEY的元素
    containsKey(_key: T1): boolean {
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].key == _key) {
                bln = true;
            }
        }
        return bln;
    };
    //判断MAP中是否含有指定VALUE的元素
    containsValue = function (_value: T2): boolean {
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].value == _value) {
                bln = true;
            }
        }
        return bln;
    };

    //判断MAP中是否含有指定VALUE的元素
    containsObj(_key: T1, _value: T2): boolean {
        var bln = false;
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].value == _value && this.elements[i].key == _key) {
                bln = true;
            }
        }
        return bln;
    };

    //获取MAP中所有VALUE的数组（ARRAY）
    values(): Array<T2> {
        var arr = new Array();
        for (let i = 0; i < this.elements.length; i++) {
            arr.push(this.elements[i].value);
        }
        return arr;
    };

    //获取MAP中所有VALUE的数组（ARRAY）
    valuesByKey(_key: T1): Array<T2> {
        var arr = new Array();
        for (let i = 0; i < this.elements.length; i++) {
            if (this.elements[i].key == _key) {
                arr.push(this.elements[i].value);
            }
        }
        return arr;
    };

    //获取MAP中所有KEY的数组（ARRAY）
    keys(): Array<T1> {
        var arr = new Array();
        for (let i = 0; i < this.elements.length; i++) {
            arr.push(this.elements[i].key);
        }
        return arr;
    };

    //获取key通过value
    keysByValue(_value: T2): Array<T1> {
        var arr = new Array();
        for (let i = 0; i < this.elements.length; i++) {
            if (_value == this.elements[i].value) {
                arr.push(this.elements[i].key);
            }
        }
        return arr;
    };

    //获取MAP中所有KEY的数组（ARRAY）
    keysRemoveDuplicate(): Array<T1> {
        var arr = new Array();
        for (let i = 0; i < this.elements.length; i++) {
            let flag = true;
            for (let j = 0;j < arr.length; j++) {
                if (arr[j] == this.elements[i].key) {
                    flag = false;
                    break;
                }
            }
            if (flag) {
                arr.push(this.elements[i].key);
            }
        }
        return arr;
    }
}