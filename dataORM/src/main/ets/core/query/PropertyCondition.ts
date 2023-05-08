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

import { AbstractCondition } from './AbstractCondition'
import { Property } from '../Property'
import { SqlUtils } from '../internal/SqlUtils'
import dataRdb from '@ohos.data.relationalStore'
import { StringBuilder } from '../StringBuilder'

export class PropertyCondition extends AbstractCondition {
    public property: Property;
    public op: string;
    public predicates: dataRdb.RdbPredicates;

    setPredicates(predicates: dataRdb.RdbPredicates): PropertyCondition {
        this.predicates = predicates;
        return this;
    }

    getPredicates(): dataRdb.RdbPredicates {
        return this.predicates;
    }

    public constructor(property: Property, op: string, value?: any, values?: any[],) {
        if (value == undefined && values == undefined) {
            super(null, null);
            this.property = property;
            this.op = op;
        } else if (value != undefined && values == undefined) {
            super(PropertyCondition.checkValueForType(property, value));
            this.property = property;
            this.op = op;
        } else if (values != undefined) {
            super(PropertyCondition.checkValueForType(property, value), PropertyCondition.checkValuesForType(property, values));
            this.property = property;
            this.op = op;
        }
    }

    static checkValueForType(property: Property, value: any): any {
        if (value != null && value instanceof Array) {
            throw new Error("Illegal value: found array, but simple object required");
        }
        let type_s: any = property.type;
        if (type_s == "Date") {
            if (value instanceof String) {
                return value;
            }
        } else if (property.type == "boolean" || property.type == "Boolean") {
            if (value instanceof Boolean) {
                return value ? 1 : 0;
            } else if (value instanceof Number) {
                let intValue: number = (<number> value);
                if (intValue != 0 && intValue != 1) {
                    throw new Error("Illegal boolean value: numbers must be 0 or 1, but was " + value);
                }
            } else if (value instanceof String) {
                let stringValue: string = value.toString();
                if ("TRUE" === stringValue.toUpperCase()) {
                    return 1;
                } else if ("FALSE" === stringValue.toUpperCase()) {
                    return 0;
                }
                else {
                    throw new Error(
                        "Illegal boolean value: Strings must be \"TRUE\" or \"FALSE\" (case insensitive), but was "
                        + value);
                }
            }
        }
        return value;
    }

    static checkValuesForType(property: Property, values: any[]): any[] {
        for (let i = 0; i < values.length; i++) {
            values[i] = this.checkValueForType(property, values[i]);
        }
        return values;
    }

    public appendTo(builder: StringBuilder, tableAlias: string) {
        let s = SqlUtils.appendProperty("", tableAlias, this.property).concat(this.op);
        builder.append(s);
    }
}



