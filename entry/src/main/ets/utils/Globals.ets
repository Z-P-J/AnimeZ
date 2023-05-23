import Logger from './Logger';
import HashMap from '@ohos.util.HashMap';


export default class Globals {

  static get<T>(key: string, buildFunc: () => T): T {
    let value = globalThis[key]
    if (!value) {
      value = buildFunc()
      globalThis[key] = value
    }
    return value
  }

  static getGlobalMap(): HashMap<any, any> {
    return Globals.get<HashMap<any, any>>('global_map', () => {
      return new HashMap<any, any>()
    })
  }

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

  static remove<T>(key: any): T {
    return this.getGlobalMap().remove(key)
  }

}