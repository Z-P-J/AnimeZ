import { Downloader } from './Downloader';
import HashMap from '@ohos.util.HashMap';
import Logger from '../utils/Logger'
import Globals from '../utils/Globals'

export interface Callback {

    (path: string): void;

}

export class ZDownloader {
    static a: number = 0;

//    private static readonly MAP_DOWNLOADER = new HashMap<any, any>();

    static get<T extends Downloader>(clazz: { new(): T }): T {
        Logger.e(this, 'get clazz type=' + (typeof clazz))
        return Globals.getOrCreate('downloader_' + clazz.name, () => {
            return new clazz();
        })


//        let downloaderMap = Globals.get<HashMap<any, any>>('downloader_map', () => {
//            return new HashMap<any, any>()
//        })
//
//        Logger.e(this, 'downloaderMap=' + downloaderMap )
//        let downloader = downloaderMap.get(clazz);
//        if (!downloader) {
//            downloader = new clazz();
//            downloaderMap.set(clazz, downloader);
//        }
//        return downloader;
    }

//    static newTask(url: string, dir: string): DownloadTask {
//
//        return new TaskBuilder(url, dir).build()
//
//        //        let downloadTask = new DownloadTask(ROOT_TASK_MANAGER, url, dir);
//        //        ROOT_TASK_MANAGER.add(downloadTask);
//        //        return downloadTask;
//    }
//
//    download(url: string, dir: string, callback: Callback): number {
//        Logger.d(this, 'download url=' + url + ' dir=' + dir);
//
//        let downloadTask = new TaskBuilder(url, dir).build()
//
//
//        //        let downloadTask = new DownloadTask(ROOT_TASK_MANAGER, url, dir);
//        //        ROOT_TASK_MANAGER.add(downloadTask);
//        //        downloadTask.statusManager.addObserver({
//        //            onStatusChanged: (_, __, status) => {
//        //                Logger.debug(TAG, "callback onStatusChanged status=" + status)
//        //                if (status == TaskStatus.COMPLETE) {
//        //                    if (callback) {
//        //                        callback.call(this, downloadTask.getFilePath())
//        //                    }
//        //                }
//        //            }
//        //        });
//        downloadTask.addObserver({
//            onPreparing: () => {
//                Logger.d(this, "download onPreparing");
//            },
//            onStart: () => {
//                Logger.d(this, "download onStart");
//            },
//            onWaiting: () => {
//                Logger.d(this, "download onWaiting");
//            },
//            onPaused: () => {
//                Logger.d(this, "download onPaused");
//            },
//            onProgress: (totalSize: number, receivedSize: number, progress: number) => {
//                Logger.d(this, "download onProgress total: " + totalSize + " received: " + receivedSize + " progress: " + progress);
//            },
//            onError: (errorMessage) => {
//                Logger.d(this, "download onError: " + errorMessage);
//            },
//            onFinished: () => {
//                Logger.d(this, "download onFinished");
//                if (callback) {
//                    callback.call(this, downloadTask.getFilePath())
//                }
//            },
//        })
//        downloadTask.start();
//        return 0;
//    }
//
//    pause(taskId: number) {
//
//    }
}