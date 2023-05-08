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

import { AbstractDaoSession } from './AbstractDaoSession';
import { Database } from './database/Database';
import { IdentityScopeType } from './identityscope/IdentityScopeType';
import { DaoConfig } from './internal/DaoConfig';
import { JMap } from './common/JMap';
import { BaseDao } from './BaseDao';

export class DaoSession extends AbstractDaoSession {
    private daoConfigObj = {};
    private daoObj = {};

    constructor(db: Database, type_s: IdentityScopeType,
                daoConfigMap: JMap<string
                , DaoConfig>) {
        super(db);

        let entities = globalThis.entityClsArr;
        if (entities) {
            for (let entity of entities) {
                this.daoConfigObj[entity.name] = daoConfigMap.get(entity.name);
                this.daoConfigObj[entity.name].initIdentityScope(type_s);

                let daosessions:DaoSession=this
                if (this.daoObj == undefined) {
                    this.daoObj = {};
                }
                this.daoObj[entity.name+'Dao'] = new BaseDao<typeof entity, number>(this.daoConfigObj[entity.name], daosessions);
                this.daoObj[entity.name+'Dao'].setEntityCls(entity);
                this.registerDao(entity.name, this.daoObj[entity.name+'Dao']);
            }
        }
    }

    public clear() {
        if (this.daoConfigObj) {
            for (let daoConfigName in this.daoConfigObj) {
                this.daoConfigObj[daoConfigName].clearIdentityScope();
            }
        }
    }

    public getBaseDao<T, K>(entity: any): BaseDao<T, K> {
        if (this.daoObj != undefined) {
            return this.daoObj[entity.name+'Dao'];
        } else {
            return undefined;
        }
    }
}
