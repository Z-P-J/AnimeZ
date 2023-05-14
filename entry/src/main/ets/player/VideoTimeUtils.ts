import Logger from '../utils/Logger';

export default class VideoTimeUtils {

    static stringForTime(timeMs: number): string {
        let totalSeconds = (timeMs / 1000);
        let seconds = totalSeconds % 60;
        let minutes = (totalSeconds / 60) % 60;
        let hours = totalSeconds / 3600;
        Logger.e(this, "stringForTime hours:" + hours + ",minutes:" + minutes + ",seconds:" + seconds);
        hours = this.completionNum(Math.floor(Math.floor(hours * 100) / 100));
        minutes = this.completionNum(Math.floor(Math.floor(minutes * 100) / 100));
        seconds = this.completionNum(Math.floor(Math.floor(seconds * 100) / 100));
        if (hours > 0) {
            return hours + ":" + minutes + ":" + seconds;
        } else {
            return minutes + ":" + seconds;
        }
    }

    private static completionNum(num: any): any {
        if (num < 10) {
            return '0' + num;
        } else {
            return num;
        }
    }

}