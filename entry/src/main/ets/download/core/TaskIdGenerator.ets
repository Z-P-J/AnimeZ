import Logger from '../../utils/Logger';
import DataStore from '../../utils/DataStore';


const KEY_TASK_ID = 'key_task_id'

/**
 * 任务id生成器
 */
export default class TaskIdGenerator {

  static getNextId(): number {
    // DataStore中获取保存的下一个id
    let id = DataStore.getInt(KEY_TASK_ID, 0)
    Logger.e(this, 'getNextId id=' + id + ' type=' + (typeof id))
    // 可能会被转换为字符串类型，需要转换成数字
    if (typeof id === 'string') {
      id = parseInt(id)
    }
    // 更新下一个id
    DataStore.set<number>(KEY_TASK_ID, id + 1)
    return id;
  }

}