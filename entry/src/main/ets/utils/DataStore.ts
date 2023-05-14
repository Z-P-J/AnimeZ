
/**
 * 配置保存与获取
 */
export default class DataStore {

    static get<T>(key: string, defaultValue?: T): T | undefined {
        if (!AppStorage.Has(key)) {
            // 初始化Persist属性
            PersistentStorage.PersistProp<T>(key, defaultValue)
        }
        return AppStorage.Get<T>(key)
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