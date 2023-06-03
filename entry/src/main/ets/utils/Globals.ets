import Logger from './Logger';
import HashMap from '@ohos.util.HashMap';

/**
 * 全局存取对象
 */
export default class Globals {

  /**
   * 根据字符串类型的key获取全局保存的对象，如果不存在则新创建一个
   * @param key 保存对象的key
   * @param buildFunc 对象创建函数
   */
  static get<T>(key: string, buildFunc: () => T): T {
    let value = globalThis[key]
    if (!value) {
      value = buildFunc()
      globalThis[key] = value
    }
    return value
  }

  /**
   * 用于保存全局对象的map，主要是可以保存any类型的key和value
   */
  static getGlobalMap(): HashMap<any, any> {
    return Globals.get<HashMap<any, any>>('global_map', () => {
      return new HashMap<any, any>()
    })
  }

  /**
   * 根据key获取全局保存的对象，如果不存在则新创建一个
   * @param key 保存对象的key
   * @param buildFunc 对象创建函数
   */
  static getOrCreate<T>(key: any, buildFunc: () => T): T {
    let globalMap = this.getGlobalMap()
    let value = globalMap.get(key)
    Logger.e(this, 'getOrCreate key=' + key + ' value=' + value)
    if (!value) {
      value = buildFunc()
      globalMap.set(key, value)
    }
    return value
  }

  /**
   * 根据key移除全局对象
   * @param key 保存对象的key
   */
  static remove<T>(key: any): T {
    return this.getGlobalMap().remove(key)
  }

}