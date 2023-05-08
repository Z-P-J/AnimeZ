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

// @ts-nocheck
import { Database } from './database/Database';
import { IdentityScope } from './identityscope/IdentityScope';
import { DaoConfig } from './internal/DaoConfig';
import { Property } from './Property';
import { AbstractDao } from './AbstractDao';

/** Reserved for internal unit tests that want to access some non-public methods. Don't use for anything else. */
export class InternalUnitTestDaoAccess <T, K> {
    private dao: AbstractDao<T, K>;

    constructor(db: Database, daoClass: AbstractDao, identityScope: IdentityScope<any, any>) {
        let daoConfig: DaoConfig = new DaoConfig(db, daoClass);
        daoConfig.setIdentityScope(identityScope);

        this.dao = new AbstractDao(daoConfig);
    }

    public getKey(entity: T): K {
        return this.dao.getKey(entity);
    }

    public getProperties(): Property[] {
        return this.dao.getProperties();
    }

    public isEntityUpdateable(): boolean {
        return this.dao.isEntityUpdateable();
    }

    public readEntity(cursor: ResultSet, offset: number): T  {
        return this.dao.readEntity(cursor, offset);
    }

    public readKey(cursor: ResultSet, offset: number): K {
        return this.dao.readKey(cursor, offset);
    }

    public getDao(): AbstractDao<T, K> {
        return this.dao;
    }
}
