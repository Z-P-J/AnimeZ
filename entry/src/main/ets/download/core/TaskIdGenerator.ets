import Logger from '../../utils/Logger';
import DataStore from '../../utils/DataStore';


const KEY_TASK_ID = 'key_task_id'

export default class TaskIdGenerator {

  static getNextId(): number {
    let id = DataStore.get(KEY_TASK_ID, 0)
    Logger.e(this, 'getNextId id=' + id + ' type=' + (typeof id))
    if (id > 10000) {
      DataStore.set<number>(KEY_TASK_ID, 0)
      return this.getNextId()
    }
    if (typeof id === 'string') {
      id = parseInt(id)
    }
    DataStore.set<number>(KEY_TASK_ID, id + 1)
    return id;
  }

}