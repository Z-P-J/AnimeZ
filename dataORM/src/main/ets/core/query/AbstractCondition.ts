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

import { WhereCondition } from './WhereCondition'
import { StringBuilder } from '../StringBuilder'

export class AbstractCondition implements WhereCondition {
    public hasSingleValue: boolean = false;
    public value: any = null;
    public values: any[] = null;

    constructor(value?: any, values?: any[]) {
        if (value != null) {
            this.value = value;
            this.hasSingleValue = true;
        }
        if (values != null)
        this.values = values;
    }

    public appendTo(builder: StringBuilder, tableAlias: string) {

    }

    public appendValuesTo(valuesTarget: Array<any>) {
        if (this.hasSingleValue) {
            valuesTarget.push(this.value);
        } else if (this.values != null) {
            for (let i = 0;i < this.values.length; i++) {
                valuesTarget.push(this.values[i]);
            }
        }
    }
}