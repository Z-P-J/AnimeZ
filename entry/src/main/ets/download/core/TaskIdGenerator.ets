import DataStore from '../../utils/DataStore';


const KEY_TASK_ID = 'key_task_id'

export default class TaskIdGenerator {

  static getNextId(): number {
    let id = DataStore.get(KEY_TASK_ID, 0)
    DataStore.set(KEY_TASK_ID, id + 1)
    return id;
  }

}