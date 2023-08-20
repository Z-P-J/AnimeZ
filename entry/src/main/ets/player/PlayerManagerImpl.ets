import media from '@ohos.multimedia.media';
import IPlayer from './IPlayer';
import IPlayerManager, { PlayerStatus, VideoFit, PlayerListener } from './IPlayerManager';
import window from '@ohos.window';
import EpisodeInfo from '../entity/EpisodeInfo';
import Logger from '../utils/Logger';

/**
 * 播放器管理
 */
export default class PlayerManagerImpl implements IPlayerManager {
  private url: string
//  private episode: EpisodeInfo
  private episodeList: EpisodeInfo[] = []
  private episodeIndex: number = 0
  private readonly listeners: PlayerListener[] = []
  private status: number = PlayerStatus.IDLE
  private fullScreenMode: boolean = false

  private totalTime: number = 0
  private currentTime: number = 0
  private videoSpeed: number = PlaybackSpeed.Speed_Forward_1_00_X

  private player: IPlayer;

  private playAfterInit: boolean = false

  init(player: IPlayer) {
    this.player = player
    Logger.e(this, 'init url=' + this.url)
    if (this.url && this.status == PlayerStatus.IDLE && !this.isInitializing) {
      this.isInitializing = true
      this.player.setDataSource(this.url)
    }
  }

//  async setEpisode(episode: EpisodeInfo) {
//    if (this.episode == episode) {
//      return
//    }
//    this.episode = episode;
//    this.listeners.forEach((l) => {
//      l.onEpisodeChanged(episode)
//    })
//    await this.setPlayerUrl(episode.videoUrl)
//  }

  async playEpisode(episode: EpisodeInfo) {
//    if (this.episode == episode) {
//      return
//    }
//    this.episode = episode;
//    this.listeners.forEach((l) => {
//      l.onEpisodeChanged(episode)
//    })
    Logger.e(this, '')
    await this.setPlayerUrl(episode.videoUrl)
    await this.start()
  }

//  getEpisode(): EpisodeInfo {
//    return this.episode
//  }

  async playEpisodeList(episodeList: EpisodeInfo[], episodeIndex: number = 0): Promise<void> {
    Logger.e(this, 'playEpisodeList index=' + episodeIndex + ' episodeList=' + JSON.stringify(episodeList))
    this.episodeList = episodeList
    this.episodeIndex = episodeIndex
    this.listeners.forEach((l) => {
      l.onEpisodeChanged(this.episodeList, this.episodeIndex)
    })
    const episode = this.episodeList[this.episodeIndex]
    if (episode.videoUrl) {
      await this.playEpisode(episode)
    }
  }

//  async playEpisodeAt(episodeIndex: number): Promise<void> {
//    if (this.episodeList == episodeIndex) {
//
//    }
//    this.episodeIndex = episodeIndex
//    await this.playEpisode(this.episodeList[episodeIndex])
//  }

//  getEpisodeList(): EpisodeInfo[] {
//    // TODO 获取播放列表
//    return []
//  }

  private isInitializing = false

  async setPlayerUrl(url: string) {
    Logger.e(this, 'setPlayerUrl status=' + this.status + ' url=' + url)
    this.url = url;
    if (this.player) {
      if (this.isPlaying()) {
        await this.player.stop()
      }
      this.isInitializing = true
      this.currentTime = 0
      if (this.status != PlayerStatus.IDLE) {
        await this.player.reset()
        this.status = PlayerStatus.IDLE
      }
      await this.player.setDataSource(url)
    }
  }

  async start(): Promise<void> {
    Logger.e(this, 'start isPlaying=' + this.isPlaying() + ' status=' + this.status + ' url=' + this.url)
    if (!this.url || this.isPlaying()) {
      return
    }
    if (this.status == PlayerStatus.IDLE) {
      this.playAfterInit = true
      if (this.player && !this.isInitializing) {
        this.isInitializing = true
        await this.player.setDataSource(this.url)
      }
      return
    }
    if (this.player) {
      if (this.status == PlayerStatus.PAUSE) {
        await this.player.start()
      } else if (this.status == PlayerStatus.INITIALIZED) {
        await this.player.prepare()
      } else if (this.status == PlayerStatus.ERROR) {
//        await this.stop()
//        // TODO验证是否有问题
//        await this.player.prepare()
        this.isInitializing = true
        this.currentTime = 0
        await this.player.reset()
        this.status = PlayerStatus.IDLE
        await this.player.setDataSource(this.url)
      } else {
        await this.player.setSpeed(this.videoSpeed)
        await this.player.seekTo(this.currentTime)
        await this.player.start()
      }
    } else {
      this.playAfterInit = true
    }
  }

  async pause() {
    if (this.player) {
      Logger.e(this, 'pause isPlaying=' + this.isPlaying() + ' status=' + this.status)
      if (this.isPlaying()) {
        await this.player.pause()
      }
    }
  }

  async stop() {
    if (this.player) {
      this.totalTime = 0
      this.currentTime = 0
      await this.player.stop();
    }
  }

  async seekTo(value: number) {
    if (this.player) {
      await this.player.seekTo(value)
      this.notifyBuffering(media.BufferingInfoType.BUFFERING_START, 0)
      this.notifyCurrentTime(value)
    }
  }

  async setSpeed(speed: PlaybackSpeed) {
    if (this.videoSpeed == speed) {
      return
    }
    this.videoSpeed = speed
    if (this.player) {
      await this.player.setSpeed(speed)
    }
    this.listeners.forEach((l) => {
      l.onVideoSpeedChanged(speed)
    })
  }

  getSpeed(): PlaybackSpeed {
    return this.videoSpeed
  }

  isPlaying(): boolean {
    return this.player != null && this.status == PlayerStatus.PLAY
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
    Logger.e(this, 'setStatus status=' + status + ' playAfterInit=' + this.playAfterInit)
    this.status = status;
    for (let listener of this.listeners) {
      listener.onStatusChanged(status)
    }
    if (this.status == PlayerStatus.INITIALIZED) {
      this.isInitializing = false
      if (this.playAfterInit) {
        this.player.prepare()
      }
    } else if (this.status == PlayerStatus.PREPARED) {
      if (this.playAfterInit) {
        this.playAfterInit = false
        this.start()
      }
    } else if (this.status == PlayerStatus.DONE) {
      this.currentTime = 0
    }
  }

  getStatus() {
    return this.status
  }

  isPrepared() {
    return this.player && this.status >= PlayerStatus.PREPARED
  }

  notifyTime(duration: number, currentTime: number) {
    this.currentTime = currentTime
    this.totalTime = duration
    this.listeners.forEach((l) => {
      l.onProgressChange(this.totalTime, this.currentTime)
    })
  }

  notifyDuration(duration: number) {
    this.totalTime = duration
    this.listeners.forEach((l) => {
      l.onProgressChange(this.totalTime, this.currentTime)
    })
  }

  notifyCurrentTime(currentTime: number) {
    this.currentTime = currentTime
    this.listeners.forEach((l) => {
      l.onProgressChange(this.totalTime, this.currentTime)
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

    if (this.episodeList.length != 0) {
      listener.onEpisodeChanged(this.episodeList, this.episodeIndex)
    }
  }

  removeListener(listener: PlayerListener) {
    let index = this.listeners.indexOf(listener)
    if (index >= 0) {
      let result = this.listeners.splice(index, 1)
      return true
    }
    return false
  }

  destroy() {
    this.stop()
    this.listeners.length = 0
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

  onVideoSizeChanged(width: number, height: number) {
    this.listeners.forEach((l) => {
      l.onVideoSizeChange(width, height)
    })
  }

  notifyBuffering(type: media.BufferingInfoType, value: number) {
    this.listeners.forEach((l) => {
      l.onBuffering(type, value)
    })
  }
}