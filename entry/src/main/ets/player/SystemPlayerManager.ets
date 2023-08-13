import IPlayerManager, { PlayerStatus, VideoFit, PlayerListener } from './IPlayerManager';
import window from '@ohos.window';
import EpisodeInfo from '../entity/EpisodeInfo';
import Logger from '../utils/Logger';

/**
 * 播放器管理
 */
export default class SystemPlayerManager implements IPlayerManager {
  private url: string
  private episode: EpisodeInfo
  private readonly listeners: PlayerListener[] = []
  private status: number = PlayerStatus.INIT
  private fullScreenMode: boolean = false

  private totalTime: number = 0
  private currentTime: number = 0
  private videoSpeed: number = PlaybackSpeed.Speed_Forward_1_00_X
  readonly controller: VideoController = new VideoController()

  init(context: object) {
    // do nothing
  }

  setEpisode(episode: EpisodeInfo) {
    if (this.episode == episode) {
      //      this.setPlayerUrl(episode.videoUrl)
      return
    }
    this.episode = episode;
    this.listeners.forEach((l) => {
      l.onEpisodeChanged(episode)
    })
    this.setPlayerUrl(episode.videoUrl)
  }

  getEpisode(): EpisodeInfo {
    return this.episode
  }

  getEpisodeList(): EpisodeInfo[] {
    // TODO 获取播放列表
    return []
  }

  setPlayerUrl(url: string) {
    Logger.e(this, 'setPlayerUrl url=' + url)
    this.url = url;
    this.controller.stop()
    this.status = PlayerStatus.INIT
  }

  start() {
    Logger.e(this, 'start isPlaying=' + this.isPlaying() + ' status=' + this.status)
    if (this.isPlaying()) {
      return
    }
    this.setStatus(PlayerStatus.BUFFERING)
    this.controller.start()
  }

  pause() {
    Logger.e(this, 'pause isPlaying=' + this.isPlaying() + ' status=' + this.status)
    if (this.isPlaying()) {
      this.setStatus(PlayerStatus.PAUSE)
      this.controller.pause()
    }
  }

  stop() {
    this.controller.stop();
    //    this.mIjkMediaPlayer.release();
    this.setStatus(PlayerStatus.INIT)
  }

  seekTo(value: number) {
    this.setStatus(PlayerStatus.BUFFERING)
    this.controller.setCurrentTime(value, SeekMode.ClosestKeyframe)
    this.notifyCurrentTime(value)
  }

  setSpeed(speed: PlaybackSpeed) {
    if (this.videoSpeed == speed) {
      return
    }
    this.videoSpeed = speed
    this.listeners.forEach((l) => {
      l.onVideoSpeedChanged(speed)
    })
  }

  getSpeed(): PlaybackSpeed {
    return this.videoSpeed
  }

  isPlaying(): boolean {
    return this.status == PlayerStatus.PLAY
  }

  setVideoFit(videoFit: VideoFit) {
    this.listeners.forEach((l) => {
      l.onVideoFitChanged(videoFit)
    })
  }

  setStatus(status: PlayerStatus) {
    if (this.status === status) {
      return
    }
    this.status = status;
    for (let listener of this.listeners) {
      listener.onStatusChanged(status)
    }
  }

  getStatus() {
    return this.status
  }

  isPrepared() {
    return this.totalTime > 0
  }

  notifyDuration(duration: number) {
    this.totalTime = duration * 1000
    this.listeners.forEach((l) => {
      l.onProgressChange(duration, this.currentTime)
    })
  }

  notifyCurrentTime(currentTime: number) {
    this.setStatus(PlayerStatus.PLAY)
    this.currentTime = currentTime * 1000
    this.listeners.forEach((l) => {
      l.onProgressChange(this.totalTime, currentTime)
    })
  }

  getDuration(): number {
    return this.totalTime
  }

  getCurrentPosition(): number {
    return this.currentTime
  }

  addListener(listener: PlayerListener) {
    this.listeners.push(listener)
    Logger.e(this, 'addListener len=' + this.listeners.length)
  }

  removeListener(listener: PlayerListener) {
    // TODO
  }

  destroy() {
    this.stop()
  }

  isFullScreen() {
    return this.fullScreenMode
  }

  enterFullScreen() {
    if (this.fullScreenMode) {
      return
    }
    window.getLastWindow(getContext(this), (err, win) => {
      win.setWindowLayoutFullScreen(true)
      win.setWindowSystemBarEnable([])
      win.setPreferredOrientation(window.Orientation.LANDSCAPE)
      this.fullScreenMode = true
      this.listeners.forEach((listener) => {
        listener.onFullScreenChanged(true)
      })
    })
  }

  exitFullScreen() {
    if (!this.fullScreenMode) {
      return
    }
    window.getLastWindow(getContext(this), (err, win) => {
      win.setWindowLayoutFullScreen(true)
      win.setWindowSystemBarEnable(['status', 'navigation'])
      win.setPreferredOrientation(window.Orientation.PORTRAIT)
      this.fullScreenMode = false
      this.listeners.forEach((listener) => {
        listener.onFullScreenChanged(false)
      })
    })
  }

  protected onPrepared() {
    Logger.e(this, 'onPrepared')
    this.start()
  }

  protected onError(what: number, extra: number) {
    Logger.e(this, 'onError what=' + what + " extra=" + extra)
    this.setStatus(PlayerStatus.ERROR)
  }
}