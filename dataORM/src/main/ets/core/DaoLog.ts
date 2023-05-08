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

import hilog from '@ohos.hilog';

/**
 * Internal dataORM logger class.
 * 
 * @author markus
 * 
 */
export class DaoLog {
    private static TAG: string = "dataORM";
    public static VERBOSE: number = 2;
    public static DEBUG: number = 3;
    public static INFO: number = 4;
    public static WARN: number = 5;
    public static ERROR: number = 6;
    public static FATAL: number = 7;
    private static domain: number = 0xFFF0;

    public static isLoggable(level: number): boolean {
        return hilog.isLoggable(this.domain, this.TAG, level);
    }

    public static getStackTraceString(th: Error): string {
        return th.stack;
    }

    public static println(level: number, msg: string): void {
        switch (level) {
            case this.INFO:
                hilog.info(this.domain, this.TAG, "%{public}s", msg);
                break;
            case this.DEBUG:
                hilog.debug(this.domain, this.TAG, "%{public}s", msg);
                break;
            case this.WARN:
                hilog.warn(this.domain, this.TAG, "%{public}s", msg);
                break;
            case this.ERROR:
                hilog.error(this.domain, this.TAG, "%{public}s", msg);
                break;
            case this.FATAL:
                hilog.fatal(this.domain, this.TAG, "%{public}s", msg);
                break;
        }
    }

    public static v(msg: string, th?: Error): void {
        return this.println(this.FATAL, this.wrapMsg(msg, th));
    }

    public static d(msg: string, th?: Error): void {
        return this.println(this.DEBUG, msg + th.message);
    }

    public static i(msg: string, th?: Error): void {
        return this.println(this.INFO, this.wrapMsg(msg, th));
    }

    public static w(msg: string, th?: Error): void {
        return this.println(this.WARN, this.wrapMsg(msg, th));
    }

    public static e(msg: string, th?: Error): void {
        return this.println(this.ERROR, this.wrapMsg(msg, th));
    }

    public static wrapMsg(msg: string, th?: Error): string{
        let message = msg;
        if (th) {
            message += '\n';
            message += th.stack;
        }
        return message;

    }
}
