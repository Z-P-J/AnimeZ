import TaskManager from './TaskManager';
import TaskInfo from './TaskInfo';
import Task from './Task';

export default interface TaskBuilder<T extends Task<TaskInfo>> {

    readonly taskManager: TaskManager
    taskName: string;


    build(): T


//    constructor(url: string, name: string) {
//        this.url = url;
//        this.name = name;
//    }
//
//
//
//    addObserver(observer: TaskObserver) {
//
//    }
//
//    build(clazz = MultiDownloader) {
//        return ZDownloader.with(clazz).buildTask(this)
//    }
//
//    start() {
//        this.build().start();
//    }
}
