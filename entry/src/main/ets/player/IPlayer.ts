
export default interface IPlayer {

    setDebug(open: boolean);

    setDataSource(url: string);

    prepareAsync();

    start();

    stop();

    pause();

    reset();

    release();

    seekTo(msec: number);

    setSpeed(speed: string);

    getSpeed(): number;

    isPlaying(): boolean;


}