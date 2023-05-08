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

import { Property } from '../Property'
import { AbstractDao } from '../AbstractDao'
import { Database } from '../database/Database'
import { IdentityScope } from '../identityscope/IdentityScope'
import { IdentityScopeObject } from '../identityscope/IdentityScopeObject'
import { IdentityScopeType } from '../identityscope/IdentityScopeType'
import { IdentityScopeLong } from '../identityscope/IdentityScopeLong'
import { TableStatements } from './TableStatements'

export class DaoConfig {
    public db: Database;
    public tablename: string;
    public properties: Property[];
    public allColumns: string[];
    public pkColumns: string[];
    public nonPkColumns: string[];

    /** Single property PK or null if there's no PK or a multi property PK. */
    public pkProperty: Property;
    public keyIsNumeric: boolean;
    public statements: TableStatements;
    private identityScope: IdentityScope<any, any>;
    private daoConfig: DaoConfig;

    public constructor(db?: Database, entityCls?: any, source?: DaoConfig) {
        if (source != undefined) {
            this.db = source.db;
            this.tablename = source.tablename;
            this.properties = source.properties;
            this.allColumns = source.allColumns;
            this.pkColumns = source.pkColumns;
            this.nonPkColumns = source.nonPkColumns;
            this.pkProperty = source.pkProperty;
            this.statements = source.statements;
            this.keyIsNumeric = source.keyIsNumeric;
            this.daoConfig = source;
        } else {
            this.db = db;
            this.tablename = AbstractDao.TABLENAME(entityCls);
            let properties: Property[] = AbstractDao.generatorProperties(entityCls);
            this.properties = properties;

            this.allColumns = [];
            let pkColumnList = new Array<string>();
            let nonPkColumnList = new Array<string>();
            let lastPkProperty: Property = null;
            for (let i = 0; i < properties.length; i++) {
                let property = properties[i];
                let name = property.columnName;
                this.allColumns[i] = name;
                if (property.primaryKey) {
                    pkColumnList.push(name);
                    lastPkProperty = property;
                } else {
                    nonPkColumnList.push(name);
                }
            }

            this.nonPkColumns = nonPkColumnList;
            this.pkColumns = pkColumnList;
            this.pkProperty = this.pkColumns.length == 1 ? lastPkProperty : null;
            this.statements = new TableStatements(db, this.tablename, this.nonPkColumns, this.pkColumns);

            if (this.pkProperty != null) {
                let types = this.pkProperty.type;
                this.keyIsNumeric = types == 'number' || types == 'Number' || types == 'bigint' || types == 'BigInt';
            } else {
                this.keyIsNumeric = false;
            }
        }

    }

    private static reflectProperties(daoClass: string): Property[] {
        return [];
    }

    public clone(): DaoConfig {
        return this.daoConfig;
    }

    public getIdentityScope(): IdentityScope<any, any>{
        return this.identityScope;
    }

    /**
     * Clears the identify scope if it exists.
     */
    public clearIdentityScope() {
        let identityScope: IdentityScope<any, any> = this.identityScope;
        if (identityScope != null) {
            identityScope.clear();
        }
    }

    public setIdentityScope(identityScope: IdentityScope<any, any>) {
        this.identityScope = identityScope;
    }

    public initIdentityScope(type: IdentityScopeType): void {
        if (type == IdentityScopeType.None) {
            this.identityScope = null;
        } else if (type == IdentityScopeType.Session) {
            if (this.keyIsNumeric) {
                this.identityScope = new IdentityScopeLong();
            } else {
                this.identityScope = new IdentityScopeObject();
            }
        } else {
            throw new Error("Unsupported type: " + type);
        }
    }
}
