import TaskIdGenerator from './TaskIdGenerator';
import TaskInfo from './TaskInfo';
import TaskRepository from './TaskRepository';
import Task from './Task';
import Logger from '../../utils/Logger'
import fs from '@ohos.file.fs';

export enum TaskStatus {
  CREATED = 0,
  PREPARING,
  WAITING,
  RUNNING,
  PAUSED,
  ERROR,
  COMPLETE,
}

export interface TaskStatusObserver {

  onStatusChanged(task: Task, oldStatus: TaskStatus, status: TaskStatus): void;

}

export interface TaskManagerObserver<T extends Task = Task> {
  onMissionLoaded(tasks: T[])

  onMissionCreateFailed(task: T, error: any);

  onMissionAdd(task: T);

  onMissionDelete(task: T);

  onMissionFinished(task: T);

  //        void onMissionConflict(Mission mission, ConflictPolicy.Callback callback);
}

export default abstract class TaskManager<P extends Task = Task, T extends Task = Task> {
  parentTask: P;
  maxDownloadingCount = 3;
  //    finishedCount = 0;
  runningCount = 0;

  //    downloadingTasks: C[] = [];
  //    finishedTasks: C[] = [];
  readonly tasks: T[] = [];
  taskRepository: TaskRepository
  private childStatusObserver: TaskStatusObserver = null;
  private observers: TaskManagerObserver<T>[] = null
  private isTaskLoaded: boolean = false
  private isLoading: boolean = false;

  constructor(parentTask: P, taskRepository: TaskRepository) {
    this.parentTask = parentTask;
    this.taskRepository = taskRepository
    //    this.loadTasks()
  }

  abstract createTask(taskInfo: TaskInfo): T;

  loadTasks() {
    Logger.e(this, 'loadTasks')
    if (this.isTaskLoaded || this.isLoading) {
      return
    }
    if (this.taskRepository) {
      this.isLoading = true;
      this.taskRepository.queryAll(this.getParentTaskId())
        .then((infoList) => {
          Logger.d(this, 'queryAll finished!')
          infoList.forEach((info) => {
            this.tasks.push(this.createTask(info))
          })
          this.isLoading = false;
          this.isTaskLoaded = true

          if (this.observers) {
            this.observers.forEach((o) => {
              o.onMissionLoaded(this.tasks)
            })
          }
        })
        .catch((e) => {
          Logger.d(this, 'queryAll failed! e=' + JSON.stringify(e))
        })
    }
  }

  generateTaskId(): number {
    return TaskIdGenerator.getNextId()
  }

  getParentManager() {
    if (this.parentTask) {
      return this.parentTask.manager;
    }
    return null;
  }

  getParentTaskId() {
    if (this.parentTask) {
      return this.parentTask.taskInfo.taskId
    }
    return -1;
  }

  addObserver(observer: TaskManagerObserver<T>) {
    if (!this.observers) {
      this.observers = []
    }
    this.observers.push(observer)
    if (this.isTaskLoaded) {
      observer.onMissionLoaded(this.tasks)
    }
  }

  removeObserver(observer: TaskManagerObserver<T>): boolean {
    if (this.observers) {
      let index = this.observers.indexOf(observer);
      if (index >= 0) {
        this.observers.splice(index, 1);
        if (this.observers.length == 0) {
          this.observers = null;
        }
        return true;
      }
    }
    return false;
  }

  addTask(task: T) {
    if (!this.childStatusObserver) {
      this.childStatusObserver = {
        onStatusChanged: (task: T, oldStatus: TaskStatus, status: TaskStatus) => {

          this.updateTaskInfo(task)

          if (status == TaskStatus.COMPLETE) {
            if (this.observers) {
              this.observers.forEach((o) => {
                o.onMissionFinished(task)
              })
            }
          }

          if (oldStatus == TaskStatus.RUNNING || oldStatus == TaskStatus.PREPARING) {
            if (status == TaskStatus.ERROR || status == TaskStatus.COMPLETE) {
              Logger.d(this, "onStatusChanged runningCount=" + this.runningCount);
              --this.runningCount;
              this.startNext();
            }
          }
        }
      };
    }
    task.addStatusObserver(this.childStatusObserver);
    this.tasks.push(task);
  }

  pause(task: T) {
    let status = task.statusManager.getStatus();
    if (status == TaskStatus.COMPLETE || status == TaskStatus.ERROR || status == TaskStatus.CREATED) {
      return;
    }
    if (status != TaskStatus.WAITING) {
      --this.runningCount;
    }
    task.statusManager.setStatus(TaskStatus.PAUSED);
    task.doPause();
  }

  start(task: T) {
    if (this.tasks.indexOf(task) < 0) {
      Logger.w(this, 'start task not in download queue!')
      return
    }
    let status = task.getStatus();
    Logger.d(this, 'download start, id=' + task.getTaskId() + ', status=' + status);
    if (status == TaskStatus.COMPLETE || status == TaskStatus.RUNNING || (status == TaskStatus.PREPARING && !task.isPrepared())) {
      Logger.w(this, 'download start return');
      return;
    }

    //    if (this.runningCount < this.maxDownloadingCount) {
    //      if (status != TaskStatus.PREPARING) {
    //        ++this.runningCount;
    //      }
    //      if (task.isPrepared()) {
    //        this.process(task);
    //      } else {
    //        this.init(task);
    //      }
    //    } else if (status != TaskStatus.WAITING) {
    //      this.wait(task);
    //    }


    if (status == TaskStatus.CREATED) {
      this.taskRepository.create(task.taskInfo)
        .then((result) => {
          Logger.d(this, 'start create result=' + result)
          if (this.observers) {
            this.observers.forEach((o) => {
              o.onMissionAdd(task)
            })
          }
          this.startInner(task)
        })
        .catch((e) => {
          Logger.e(this, 'start create e=' + JSON.stringify(e))
          if (this.observers) {
            this.observers.forEach((o) => {
              o.onMissionCreateFailed(task, e)
            })
          }
        })
    } else {
      this.startInner(task)
    }
  }

  private startInner(task: T) {
    Logger.d(this, 'startInner id=' + task.getTaskId())
    if (this.runningCount < this.maxDownloadingCount) {
      if (task.getStatus() != TaskStatus.PREPARING) {
        ++this.runningCount;
      }
      if (task.isPrepared()) {
        this.process(task);
      } else {
        this.init(task);
      }
    } else if (task.getStatus() != TaskStatus.WAITING) {
      this.wait(task);
    }
  }

  wait(task: T) {
    Logger.d(this, 'download doWaiting, id=' + task.taskInfo.taskId);
    task.statusManager.setStatus(TaskStatus.WAITING);
    task.doWaiting();
  }

  init(task: T) {
    Logger.d(this, 'download doInit, id=' + task.taskInfo.taskId);
    //        task.redirectCount = 0;
    task.statusManager.setStatus(TaskStatus.PREPARING);
    task.doInit();
  }

  process(task: T) {
    Logger.d(this, 'download doStart, id=' + task.taskInfo.taskId);
    task.statusManager.setStatus(TaskStatus.RUNNING);
    task.doStart();
  }

  delete(task: T) {
    this.pause(task)
    this.taskRepository.delete(task.taskInfo)
      .then((result) => {
        Logger.e(this, 'delete result=' + result)
        let index = this.tasks.indexOf(task);
        if (index >= 0) {
          this.tasks.splice(index, 1);
        }
        if (this.observers) {
          this.observers.forEach((o) => {
            o.onMissionDelete(task)
          })
        }
        task.doDelete()
      })
      .catch((e) => {
        Logger.e(this, 'delete failed! e=' + JSON.stringify(e))
        task.statusManager.onError(JSON.stringify(e))
      })

  }

  startAll() {
    this.tasks.forEach((task: T) => {
      this.start(task);
    })
  }

  startNext() {
    let isComplete = this.runningCount == 0;
    let errorMessage = null;
    Logger.d(this, "startNext runningCount=" + this.runningCount + " len=" + this.tasks.length);
    for (let i = 0; i < this.tasks.length; i++) {
      let status = this.tasks[i].getStatus();
      if (isComplete) {
        if (status == TaskStatus.COMPLETE) {
          continue;
        } else {
          isComplete = false;
        }
      }
      if (status == TaskStatus.ERROR) {
        if (!errorMessage) {
          errorMessage = this.tasks[i].statusManager.getMessage();
        }
      } else if (status == TaskStatus.WAITING) {
        Logger.d(this, 'start next id=' + this.tasks[i].getTaskId())
        this.start(this.tasks[i]);
        break;
      }
    }

    Logger.d(this, "startNext isComplete=" + isComplete + " parent=" + this.parentTask);
    if (this.parentTask) {
      if (isComplete) {
        this.parentTask.statusManager.setStatus(TaskStatus.COMPLETE);
      } else if (this.runningCount == 0) {
        if (errorMessage) {
          this.parentTask.statusManager.onError(errorMessage);
        } else {
          this.parentTask.statusManager.setStatus(TaskStatus.PAUSED);
        }
      } else {
        this.parentTask.statusManager.setStatus(TaskStatus.RUNNING);
      }
    }
  }

  waitingAll() {
    this.tasks.forEach((task) => {
      if (task.isWaiting()) {
        return;
      }
      if (task.canPause()) {
        task.pause();
      }
      task.statusManager.setStatus(TaskStatus.WAITING);
      task.doWaiting();
    });
  }

  pauseAll() {
    this.tasks.forEach((task) => {
      if (task.canPause()) {
        task.pause();
      }
    });
  }

  onProgressChanged(task: T) {
    this.updateTaskInfo(task)
  }

  private updateTaskInfo(task: T) {
    Logger.d(this, 'updateTaskInfo info=' + JSON.stringify(task.taskInfo))
    this.taskRepository.update(task.taskInfo)
      .then((result) => {
        Logger.d(this, 'update success! result=' + result + ', info=' + JSON.stringify(task.taskInfo))
      })
      .catch((e) => {
        Logger.e(this, 'update failed! e=' + JSON.stringify(e) + ', info=' + JSON.stringify(task.taskInfo))
        // TODO
      })
  }

  //    addObserver(observer: TaskObserver) {
  //        if (this.parentTask) {
  //            this.parentTask.addObserver(observer);
  //        }
  //    }
  //
  //    removeObserver(observer: TaskObserver): boolean {
  //        if (this.parentTask) {
  //            return this.parentTask.removeObserver(observer);
  //        }
  //    }
  //
  //    notifyStart() {
  //        if (this.parentTask) {
  //            this.parentTask.observerDispatcher.notifyStart()
  //        }
  //    }
  //
  //    notifyPreparing() {
  //        if (this.parentTask) {
  //            this.parentTask.observerDispatcher.notifyPreparing()
  //        }
  //    }
  //
  //    notifyPaused() {
  //        if (this.parentTask) {
  //            this.parentTask.observerDispatcher.notifyPaused()
  //        }
  //    }
  //
  //    notifyWaiting() {
  //        if (this.parentTask) {
  //            this.parentTask.observerDispatcher.notifyWaiting()
  //        }
  //    }
  //
  //    notifyFinished() {
  //        this.notifyProgress();
  //        if (this.parentTask) {
  //            this.parentTask.observerDispatcher.notifyFinished()
  //        }
  //    }
  //
  //    notifyProgress() {
  //        if (this.parentTask) {
  //            let totalSize = this.parentTask.getTotalSize();
  //            let receivedSize = this.parentTask.getReceivedSize();
  //            let downloadProgress = this.parentTask.getProgress();
  //            this.parentTask.observerDispatcher.notifyProgress(totalSize, receivedSize, downloadProgress);
  //        }
  //    }
  //
  //    notifyError() {
  //        if (this.parentTask) {
  //            let message = this.parentTask.statusManager.getMessage();
  //            this.parentTask.observerDispatcher.notifyError(message)
  //        }
  //    }
}


//class BlockTaskManager extends BaseTaskManager<BlockTask> {
//    constructor(parentTask: DownloadTask) {
//        super(parentTask);
//    }
//}
//
//
///**
// * 管理所有Task
// */
//class DownloadTaskManager extends BaseTaskManager {
//    constructor(parentTask: DownloadTask) {
//        super(parentTask);
//    }
//}