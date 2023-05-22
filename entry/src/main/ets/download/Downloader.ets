import Task from './core/Task';
import DownloadTaskRepository from './DownloadTaskRepository';
import { FileDownloadTask } from './FileDownloadTask';
import TaskInfo from './core/TaskInfo';
import TaskRepository from './core/TaskRepository';
import TaskManager from './core/TaskManager';
import DownloadTaskBuilder from './DownloadTaskBuilder';

export abstract class Downloader<T extends FileDownloadTask = FileDownloadTask> extends TaskManager<Task, T> {
    constructor(taskRepository: TaskRepository<TaskInfo> = new DownloadTaskRepository()) {
        super(null, taskRepository);
    }

//    abstract with(url: string): DownloadTaskBuilder<T>

    with(url: string): DownloadTaskBuilder<T> {
        return new DownloadTaskBuilder<T>(this, url)
    }

//    with(url: string): DownloadTaskBuilder {
//        return new DownloadTaskBuilder(0, url)
//    }

//    abstract buildTask(builder: TaskBuilder): DownloadTask;

}