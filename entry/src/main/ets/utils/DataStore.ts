import Logger from './Logger';
/**
 * 配置保存与获取
 */
export default class DataStore {

    static get<T>(key: string, defaultValue?: T): T | undefined {
        if (!AppStorage.Has(key)) {
            // 初始化Persist属性
            PersistentStorage.PersistProp<T>(key, defaultValue)
            Logger.e(this, 'get not has key=' + key)
        } else {
            Logger.e(this, 'get has key=' + key)
        }
        return AppStorage.Get<T>(key)
    }

    static getInt(key: string, defaultValue?: number): number {
        let value = this.get(key, defaultValue)
        if (typeof value == 'string') {
            return parseInt(value)
        }
        return value
    }

    static getFloat(key: string, defaultValue?: number): number {
        let value = this.get(key, defaultValue)
        if (typeof value == 'string') {
            return parseFloat(value)
        }
        return value
    }

    static getBoolean(key: string, defaultValue?: boolean): boolean {
        let value = this.get(key, defaultValue)
        if (typeof value == 'string') {
            return 'true' == value
        }
        return value
    }

    static set<T>(key: string, value: T) {
        if (AppStorage.Has(key)) {
            AppStorage.Set<T>(key, value)
        } else {
            // 初始化并保存Persist属性的值
            PersistentStorage.PersistProp<T>(key, value)
        }
    }

}