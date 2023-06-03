import { TaskStatus } from './Task';
import { TaskStatusObserver } from './Task';
import TaskIdGenerator from './TaskIdGenerator';
import TaskInfo from './TaskInfo';
import TaskInfoRepository from './TaskInfoRepository';
import Task from './Task';
import Logger from '../../utils/Logger'

/**
 * 任务管理器监听者
 */
export interface TaskManagerObserver<T extends Task = Task> {

  /**
   * 当任务加载完成
   */
  onTaskLoaded(tasks: T[])

  /**
   * 任务创建失败
   */
  onTaskCreateFailed(task: T, error: any);

  /**
   * 添加任务
   */
  onTaskAdd(task: T);

  /**
   * 移除任务
   */
  onTaskRemove(task: T);

  /**
   * 任务完成
   */
  onTaskComplete(task: T);

  // TODO 任务冲突、任务冲突策略
  // onTaskConflict(Mission mission, ConflictPolicy.Callback callback);
}

/**
 * 任务管理
 */
export default abstract class TaskManager<P extends Task = Task, T extends Task = Task> {
  parentTask: P;

  /**
   * 最大同时任务处理数
   */
  maxProcessingTaskCount = 3;

  /**
   * 处理中的任务数
   */
  processingCount = 0;

  //    downloadingTasks: T[] = [];
  //    finishedTasks: T[] = [];
  /**
   * 所有任务
   * TODO 处理中任务和已完成任务分开管理？
   */
  readonly tasks: T[] = [];

  /**
   * 任务仓库，保存任务信息
   */
  taskInfoRepository: TaskInfoRepository
  private childStatusObserver: TaskStatusObserver = null;
  private observers: TaskManagerObserver<T>[] = null
  private isTaskLoaded: boolean = false
  private isLoading: boolean = false;

  constructor(parentTask: P, taskInfoRepository: TaskInfoRepository) {
    this.parentTask = parentTask;
    this.taskInfoRepository = taskInfoRepository
    //    this.loadTasks()
  }

  abstract createTask(taskInfo: TaskInfo): T;

  /**
   * 从本地加载任务
   */
  loadTasks() {
    Logger.e(this, 'loadTasks isTaskLoaded=' + this.isTaskLoaded + ' isLoading=' + this.isLoading)
    if (this.isTaskLoaded || this.isLoading) {
      return
    }
    if (this.taskInfoRepository) {
      this.isLoading = true;
      this.loadTasksInner()
        .then(() => {
          Logger.d(this, 'loadTasksInner finished!')
          this.isLoading = false;
          this.isTaskLoaded = true

          if (this.observers) {
            this.observers.forEach((o) => {
              o.onTaskLoaded(this.tasks)
            })
          }
        })
        .catch((e) => {
          Logger.d(this, 'loadTasksInner failed! e=' + JSON.stringify(e))
        })
    }
  }

  private async loadTasksInner(): Promise<void> {
    let infoList = await this.taskInfoRepository.queryAll(this.getParentTaskId())
    Logger.d(this, 'queryAll finished! infoList=' + JSON.stringify(infoList))
    for (let info of infoList) {
      let task = this.createTask(info)
      await task.doRestore()
      this.addTaskInner(task)
    }
//    this.isLoading = false;
//    this.isTaskLoaded = true
//
//    if (this.observers) {
//      this.observers.forEach((o) => {
//        o.onTaskLoaded(this.tasks)
//      })
//    }
  }

  /**
   * 生成任务id
   */
  generateTaskId(): number {
    return TaskIdGenerator.getNextId()
  }

  /**
   * 获取父任务的任务管理器
   */
  getParentManager(): TaskManager {
    if (this.parentTask) {
      return this.parentTask.manager;
    }
    return null;
  }

  /**
   * 获取父任务id，如果父任务不存在，则返回-1
   */
  getParentTaskId(): number {
    if (this.parentTask) {
      return this.parentTask.taskInfo.taskId
    }
    return -1;
  }

  /**
   * 添加任务管理器观察者
   */
  addObserver(observer: TaskManagerObserver<T>) {
    if (!this.observers) {
      this.observers = []
    }
    this.observers.push(observer)
    if (this.isTaskLoaded) {
      observer.onTaskLoaded(this.tasks)
    }
  }

  /**
   * 移除任务管理器观察者
   */
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

  /**
   * 添加任务
   */
  addTask(task: T) {
    this.addTaskInner(task)

    if (this.observers) {
      this.observers.forEach((o) => {
        o.onTaskAdd(task)
      })
    }
  }

  private addTaskInner(task: T) {
    if (!this.childStatusObserver) {
      this.childStatusObserver = {
        onStatusChanged: (task: T, oldStatus: TaskStatus, status: TaskStatus) => {
          this.updateTaskInfo(task)
          if (status == TaskStatus.COMPLETE) {
            if (this.observers) {
              this.observers.forEach((o) => {
                o.onTaskComplete(task)
              })
            }
          }
          if (oldStatus == TaskStatus.PROCESSING || oldStatus == TaskStatus.PREPARING) {
            if (status == TaskStatus.ERROR || status == TaskStatus.COMPLETE) {
              Logger.d(this, "onStatusChanged runningCount=" + this.processingCount);
              --this.processingCount;
              this.startNext();
            }
          }
        }
      }
    }
    task.addStatusObserver(this.childStatusObserver);
    Logger.e(this, 'addTaskInner id=' + task.getTaskId())
    this.tasks.push(task);
  }

  /**
   * 暂停任务
   * @param task
   */
  pause(task: T) {
    let status = task.statusManager.getStatus();
    if (status == TaskStatus.COMPLETE || status == TaskStatus.ERROR || status == TaskStatus.CREATED) {
      return;
    }
    if (status != TaskStatus.WAITING) {
      --this.processingCount;
    }
    task.statusManager.setStatus(TaskStatus.PAUSED);
    task.doPause();
  }

  /**
   * 开始任务
   * start和process的区别：start时任务会继续进行也可能会等待；但是process是继续执行任务
   * @param task
   */
  start(task: T) {

    let result = this.tasks.find((t) => {
      return t.getTaskId() === task.getTaskId()
    })
    if (!result) {
      Logger.w(this, 'start task not in download queue! id=' + task.getTaskId())
      return
    }

    let status = task.getStatus();
    Logger.d(this, 'download start, id=' + task.getTaskId() + ', status=' + status);
    if (status == TaskStatus.COMPLETE || status == TaskStatus.PROCESSING || (status == TaskStatus.PREPARING && !task.isPrepared())) {
      Logger.w(this, 'download start return');
      return;
    }

    if (status == TaskStatus.CREATED) {
      this.taskInfoRepository.create(task.taskInfo)
        .then((result) => {
          Logger.d(this, 'start create result=' + result)
          this.startInner(task)
        })
        .catch((e) => {
          Logger.e(this, 'start create e=' + JSON.stringify(e))
          if (this.observers) {
            this.observers.forEach((o) => {
              o.onTaskCreateFailed(task, e)
            })
          }
        })
    } else {
      this.startInner(task)
    }
  }

  private startInner(task: T) {
    Logger.d(this, 'startInner id=' + task.getTaskId())
    if (this.processingCount < this.maxProcessingTaskCount) {
      if (task.getStatus() != TaskStatus.PREPARING) {
        ++this.processingCount;
      }
      Logger.e(this, 'startInner isPrepared=' + task.isPrepared())
      task.taskInfo.message = null
      if (task.isPrepared()) {
        this.process(task);
      } else {
        this.init(task);
      }
    } else if (task.getStatus() != TaskStatus.WAITING) {
      this.wait(task);
    }
  }

  /**
   * 等待任务
   * @param task
   */
  wait(task: T) {
    Logger.d(this, 'download doWaiting, id=' + task.taskInfo.taskId);
    task.statusManager.setStatus(TaskStatus.WAITING);
    task.doWaiting();
  }

  /**
   * 初始化任务
   * @param task
   */
  init(task: T) {
    Logger.d(this, 'download doInit, id=' + task.taskInfo.taskId);
    //        task.redirectCount = 0;
    task.statusManager.setStatus(TaskStatus.PREPARING);
    task.doInit();
  }

  /**
   * 处理任务
   * @param task
   */
  process(task: T) {
    Logger.d(this, 'process, id=' + task.getTaskId());
    task.statusManager.setStatus(TaskStatus.PROCESSING);
    task.doStart();
  }

  /**
   * 移除任务
   * @param task
   */
  delete(task: T) {
    Logger.e(this, 'delete, id=' + task.getTaskId())
    this.pause(task)
    this.taskInfoRepository.delete(task.taskInfo)
      .then((result) => {
        Logger.e(this, 'delete result=' + result)
        let index = this.tasks.indexOf(task);
        if (index >= 0) {
          this.tasks.splice(index, 1);
        }
        if (this.observers) {
          this.observers.forEach((o) => {
            o.onTaskRemove(task)
          })
        }
        task.doDelete()
      })
      .catch((e) => {
        Logger.e(this, 'delete failed! e=' + JSON.stringify(e))
        task.statusManager.onError(JSON.stringify(e))
      })

  }

  /**
   * 开始所有任务
   */
  startAll() {
    this.tasks.forEach((task: T) => {
      this.start(task);
    })
  }

  /**
   * 开始下一个任务
   */
  startNext() {
    let isComplete = this.processingCount == 0;
    let errorMessage = null;
    Logger.d(this, "startNext runningCount=" + this.processingCount + " len=" + this.tasks.length);
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
          errorMessage = this.tasks[i].taskInfo.message;
        }
      } else if (status == TaskStatus.WAITING) {
        Logger.d(this, 'start next id=' + this.tasks[i].getTaskId())
        this.start(this.tasks[i]);
        break;
      }
    }

    Logger.d(this, "startNext isComplete=" + isComplete + ' runningCount=' + this.processingCount + ' errorMessage=' + errorMessage + " parent=" + this.parentTask);
    if (this.parentTask) {
      if (isComplete) {
        this.parentTask.statusManager.setStatus(TaskStatus.COMPLETE);
      } else if (this.processingCount == 0) {
        if (errorMessage) {
          this.parentTask.statusManager.onError(errorMessage);
        } else {
          this.parentTask.statusManager.setStatus(TaskStatus.PAUSED);
        }
      } else {
        this.parentTask.statusManager.setStatus(TaskStatus.PROCESSING);
      }
    }
  }

  /**
   * 等待所有任务
   */
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

  /**
   * 暂停所有任务
   */
  pauseAll() {
    this.tasks.forEach((task) => {
      if (task.canPause()) {
        task.pause();
      }
    });
  }

  /**
   * 任务进度改变
   * @param task
   */
  onProgressChanged(task: T) {
    this.updateTaskInfo(task)
  }

  /**
   * 更新任务进度
   * @param task
   */
  private updateTaskInfo(task: T) {
    Logger.d(this, 'updateTaskInfo info=' + JSON.stringify(task.taskInfo))
    this.taskInfoRepository.update(task.taskInfo)
      .then((result) => {
        Logger.d(this, 'update success! result=' + result + ', info=' + JSON.stringify(task.taskInfo))
      })
      .catch((e) => {
        Logger.e(this, 'update failed! e=' + JSON.stringify(e) + ', info=' + JSON.stringify(task.taskInfo))
        // TODO
      })
  }
}