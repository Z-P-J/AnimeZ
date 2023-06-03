
/**
 * 任务观察者
 */
export default interface TaskObserver {

    /**
     * 任务准备中
     */
    onPreparing(): void;

    /**
     * 任务开始
     */
    onStart(): void;

    /**
     * 任务暂停
     */
    onPaused(): void;

    /**
     * 任务等待中
     */
    onWaiting(): void;

    /**
     * 任务进度更新
     */
    onProgress(totalSize: number, receivedSize: number, progress: number): void;

    /**
     * 任务完成
     */
    onComplete(): void;

    /**
     * 任务出错了
     */
    onError(errorMessage: string): void;

}