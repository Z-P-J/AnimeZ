export default interface TaskObserver {

    onPreparing(): void;

    onStart(): void;

    onPaused(): void;

    onWaiting(): void;

    onProgress(totalSize: number, receivedSize: number, progress: number): void;

    onFinished(): void;

    onError(errorMessage: string): void;

}