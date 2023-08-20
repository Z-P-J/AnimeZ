
export default interface IPlayer {

    setDataSource(url: string): Promise<void>;

    prepare(): Promise<void>;

    start(): Promise<void>;

    stop(): Promise<void>;

    pause(): Promise<void>;

    reset(): Promise<void>;

    release(): Promise<void>;

    seekTo(msec: number): Promise<void>;

    setSpeed(speed: PlaybackSpeed): Promise<void>;

}