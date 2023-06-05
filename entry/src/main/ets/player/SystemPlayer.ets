import IPlayer from './IPlayer';


export default class SystemPlayer implements IPlayer {

  private controller: VideoController = new VideoController();

  setDebug(open: boolean) {

  }

  setDataSource(url: string) {

  }

  prepareAsync() {

  }

  start() {
    this.controller.start()
  }

  stop() {
    this.controller.stop()
  }

  pause() {
    this.controller.pause()
  }

  reset() {
    this.stop()
  }

  release() {

  }

  seekTo(msec: number) {
    this.controller.setCurrentTime(msec)
  }

  setSpeed(speed: string) {

  }

  getSpeed(): number {
    return 0
  }

  isPlaying(): boolean {
    return false
  }


}