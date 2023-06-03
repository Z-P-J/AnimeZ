import window from '@ohos.window';
import { IjkMediaPlayer } from './IjkPlayer';
import EpisodeInfo from '../entity/EpisodeInfo';
import { IJKMediaInfo } from './IjkMediaInfo';
import { PlayerStatus } from './PlayerStatus';
import Logger from '../utils/Logger';
import promptAction from '@ohos.promptAction';

export default interface PlayerListener {

  //    onStatusChanged(status: number): void;

  (status: number): void

}

export interface ProgressListener {

  (totalTime: number, currentTime: number): void

}

export interface VideoSizeChangeListener {

  (width: number, height: number, sar_num: number, sar_den: number): void

}

export interface EpisodeChangeListener {

  (episode: EpisodeInfo): void

}

export interface FullScreenChangeListener {

  (isFullScreen: boolean): void

}

/**
 * 播放器管理
 */
export class PlayerManager {
  private readonly mIjkMediaPlayer = new IjkMediaPlayer()
  private url: string
  private episode: EpisodeInfo
  private readonly listeners: PlayerListener[] = []
  private status: number = PlayerStatus.INIT
  private videoSizeChangeListener: VideoSizeChangeListener
  private episodeChangeListener: EpisodeChangeListener
  private fullScreenMode: boolean = false
  private updateProgressTimer: number = -1
  private readonly progressListeners: ProgressListener[] = []
  private readonly fullScreenChangeListeners: FullScreenChangeListener[] = []

  init(context: object) {

    Logger.e(this, 'init context=' + context)

    //设置XComponent回调的context
    this.mIjkMediaPlayer.setContext(context);
    this.mIjkMediaPlayer.reset();

    //设置debug模式
    this.mIjkMediaPlayer.setDebug(true);
    //初始化配置
    this.mIjkMediaPlayer.native_setup();
    // 屏幕常亮
    this.mIjkMediaPlayer.setScreenOnWhilePlaying(true);

    this.initPlayer()
    this.initOptions()

    Logger.e(this, 'init url=' + this.url)
    this.setStatus(PlayerStatus.INIT)
    if (this.url) {
      this.prepare()
    }
  }

  private initPlayer() {
    let that = this;

    this.mIjkMediaPlayer.setOnVideoSizeChangedListener({
      onVideoSizeChanged(width: number, height: number, sar_num: number, sar_den: number) {
        if (typeof width == 'string') {
          width = parseInt(width)
        }
        if (typeof height == 'string') {
          height = parseInt(height)
        }
        that.onVideoSizeChanged(width, height, sar_num, sar_den)
      }
    })

    this.mIjkMediaPlayer.setOnBufferingUpdateListener({
      onBufferingUpdate(percent: number) {
        Logger.e(this, 'onBufferingUpdate p=' + percent)
//        if (percent == 100) {
//          that.setStatus(PlayerStatus.PLAY)
//        } else {
//          that.setStatus(PlayerStatus.BUFFERING)
//        }
      }
    })

    this.mIjkMediaPlayer.setOnCompletionListener({
      onCompletion() {
        Logger.e(this, 'onCompletion')
        that.setStatus(PlayerStatus.DONE)
      }
    })

    this.mIjkMediaPlayer.setOnSeekCompleteListener({
      onSeekComplete() {
        Logger.e(this, 'onSeekComplete')
      }
    })


    this.mIjkMediaPlayer.setOnErrorListener({
      onError(what: number, extra: number) {
        that.onError(what, extra)
      }
    })

    this.mIjkMediaPlayer.setOnPreparedListener({
      onPrepared() {
        that.onPrepared()
      }
    })

    this.mIjkMediaPlayer.setOnInfoListener({
      onInfo(what: number, extra: number) {
        that.onInfo(what, extra)
      }
    })

    this.mIjkMediaPlayer.setMessageListener()
  }

  private initOptions() {
    //    //使用精确寻帧 例如，拖动播放后，会寻找最近的关键帧进行播放，很有可能关键帧的位置不是拖动后的位置，而是较前的位置.可以设置这个参数来解决问题
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", "0");
    //    //预读数据的缓冲区大小
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-buffer-size", "102400");
    //    //停止预读的最小帧数
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", "100");
    //    //启动预加载
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", "1");
    //    // 设置无缓冲，这是播放器的缓冲区，有数据就播放
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", "0");
    //    //跳帧处理,放CPU处理较慢时，进行跳帧处理，保证播放流程，画面和声音同步
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", "5");
    //    // 最大缓冲cache是3s， 有时候网络波动，会突然在短时间内收到好几秒的数据
    //    // 因此需要播放器丢包，才不会累积延时
    //    // 这个和第三个参数packet-buffering无关。
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", "3000");
    //    // 无限制收流
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", "1");
    //    // 设置超时
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "timeout", "10000000");
    //    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "connect_timeout", "10000000");
    //    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "addrinfo_timeout", "10000000");
    //    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_timeout", "10000000");
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_clear", "1");
    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "reconnect", "1");
    //    //
    //    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", "48");
    //    ////    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", "1")
    //    ////    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzemaxduration", "100");
    //    //    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "probesize", '102400');


    //不用MediaCodec编解码
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", '1');
    //不用opensles编解码
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "opensles", '0');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "overlay-format", '842225234');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", '1');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", '0');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "http-detect-range-support", '0');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "timeout", '10000000');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "reconnect", '1');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", '48');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", '0');
    this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_clear", '1');
  }

  setEpisode(episode: EpisodeInfo) {
    //    if (this.episode === episode) {
    //      if (this.status == PlayerStatus.PLAY || this.status == PlayerStatus.LOADING) {
    //        return
    //      }
    //      this.status = PlayerStatus.PLAY
    //      return
    //    }
    //    this.episode = episode;
    //    if (this.episodeChangeListener) {}
    //    this.episodeChangeListener(episode)
    //    if (this.status != PlayerStatus.INIT) {
    //      this.mIjkMediaPlayer.reset()
    //      this.prepare()
    //    }

    if (this.episode == episode) {
      return
    }
    this.episode = episode;
    if (this.episodeChangeListener) {
      this.episodeChangeListener(episode)
    }
    this.setPlayerUrl(episode.videoUrl)
  }

  getEpisode(): EpisodeInfo {
    return this.episode
  }

  setPlayerUrl(url: string) {
//    if (this.url === url) {
//      if (this.status == PlayerStatus.PLAY) {
//        return
//      }
//      this.status = PlayerStatus.PLAY
//      return
//    }
    this.url = url;
    this.mIjkMediaPlayer.stop()
    this.status - PlayerStatus.INIT
    //    if (this.status != PlayerStatus.INIT) {
    //      this.mIjkMediaPlayer.reset()
    //      this.prepare()
    //    }
  }

  private prepare() {
    Logger.e(this, 'prepare url=' + this.url)
    this.setStatus(PlayerStatus.BUFFERING)
    this.mIjkMediaPlayer.setDataSource(this.url)
    this.mIjkMediaPlayer.prepareAsync()
    //    this.mIjkMediaPlayer.start()
    Logger.e(this, 'prepare start')
  }

  start() {
    Logger.e(this, 'start isPlaying=' + this.mIjkMediaPlayer.isPlaying() + ' status=' + this.status)
    if (this.mIjkMediaPlayer.isPlaying()) {
      return
    }
    if (this.status == PlayerStatus.INIT) {
      this.mIjkMediaPlayer.reset()
      this.prepare()
    } else if (this.status == PlayerStatus.ERROR) {
      //      this.setStatus(PlayerStatus.LOADING)
      //      this.mIjkMediaPlayer.start()
      this.mIjkMediaPlayer.reset()
      this.prepare()
    } else {
      this.setStatus(PlayerStatus.PLAY)
      this.mIjkMediaPlayer.start()
    }
  }

  pause() {
    Logger.e(this, 'pause isPlaying=' + this.mIjkMediaPlayer.isPlaying() + ' status=' + this.status)
    if (this.mIjkMediaPlayer.isPlaying()) {
      this.setStatus(PlayerStatus.PAUSE)
      this.mIjkMediaPlayer.pause()
    }
  }

  stop() {
    this.mIjkMediaPlayer.stop();
    //    this.mIjkMediaPlayer.release();
    this.setStatus(PlayerStatus.INIT)
  }

  seekTo(value: string) {
//    if (this.mIjkMediaPlayer.isPlaying()) {
//      this.mIjkMediaPlayer.pause()
//    }
    this.setStatus(PlayerStatus.BUFFERING)
    this.mIjkMediaPlayer.seekTo(value);
  }

  setSpeed(speed: string) {
    this.mIjkMediaPlayer.setSpeed(speed)
  }

  getSpeed(): string {
    return '' + this.mIjkMediaPlayer.getSpeed()
  }

  setDataSource(url: string) {
    this.mIjkMediaPlayer.setDataSource(url)
  }

  isPlaying(): boolean {
    return this.mIjkMediaPlayer.isPlaying();
  }

  private setStatus(status: PlayerStatus) {
    if (this.status === status) {
      return
    }
    this.status = status;

    if (status == PlayerStatus.PLAY) {
      this.startProgress()
    } else {
      this.stopProgress()
    }

    for (let listener of this.listeners) {
      listener(status)
    }

//    setTimeout(() => {
//      for (let listener of this.listeners) {
//        listener(status)
//      }
//    }, 20)
//    this.notifyStatus(status)
  }

//  private async notifyStatus(status: PlayerStatus) {
//    for (let listener of this.listeners) {
//      listener(status)
//    }
//  }

  getStatus() {
    return this.status
  }

  getDuration(): number {
    return this.mIjkMediaPlayer.getDuration()
  }

  getCurrentPosition(): number {
    return this.mIjkMediaPlayer.getCurrentPosition()
  }

  addListener(listener: PlayerListener) {
    this.listeners.push(listener)
    Logger.e(this, 'addListener len=' + this.listeners.length)
  }

  removeListener(listener: PlayerListener) {
    // TODO
  }

  addProgressListener(listener: ProgressListener) {
    this.progressListeners.push(listener)
  }

  removeProgressListener(listener: ProgressListener) {
    // TODO
  }

  setVideoSizeChangedListener(videoSizeChangeListener: VideoSizeChangeListener) {
    this.videoSizeChangeListener = videoSizeChangeListener
  }

  setEpisodeChangeListener(episodeChangeListener: EpisodeChangeListener) {
    this.episodeChangeListener = episodeChangeListener
  }

  addFullScreenChangeListener(fullScreenChangeListener: FullScreenChangeListener) {
    this.fullScreenChangeListeners.push(fullScreenChangeListener)
  }

  destroy() {
    this.stopProgress()
    this.stop()
    this.mIjkMediaPlayer.release()
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
      this.fullScreenChangeListeners.forEach((listener) => {
        listener(true)
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


      this.fullScreenChangeListeners.forEach((listener) => {
        listener(false)
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

  protected onInfo(what: number, extra: number) {
    Logger.e(this, "OnInfoListener-->go:" + what + "===" + extra);
    if (what == IJKMediaInfo.MEDIA_INFO_BUFFERING_START) {
      this.mIjkMediaPlayer.pause()
      this.setStatus(PlayerStatus.BUFFERING)
    } else if (what == IJKMediaInfo.MEDIA_INFO_BUFFERING_END) {
      // TODO buffer status
      this.setStatus(PlayerStatus.PLAY)
      this.mIjkMediaPlayer.start()
    } else if (what == IJKMediaInfo.MEDIA_INFO_VIDEO_RENDERING_START) {
      this.setStatus(PlayerStatus.PLAY)
      this.mIjkMediaPlayer.start()
    }
  }

  protected onVideoSizeChanged(width: number, height: number, sar_num: number, sar_den: number) {
    if (this.videoSizeChangeListener) {
      this.videoSizeChangeListener(width, height, sar_num, sar_den)
    }
  }

  private lastTime: number;

  private startProgress() {
    this.stopProgress()
    this.updateProgressTimer = setInterval(() => {
      if (this.updateProgressTimer < 0) {
        return
      }
      let totalTime = this.mIjkMediaPlayer.getDuration()
      let currentTime = this.mIjkMediaPlayer.getCurrentPosition()
      if (this.lastTime == currentTime) {
        return
      }
      this.lastTime = currentTime
      this.progressListeners.forEach((listener) => {
        listener(totalTime, currentTime)
      })
    }, 1000);
    Logger.e(this, 'startProgress updateProgressTimer=' + this.updateProgressTimer)
  }

  private stopProgress() {
    if (this.updateProgressTimer < 0) {
      return
    }
    let timer = this.updateProgressTimer;
    this.updateProgressTimer = -1
    clearInterval(timer)
  }
}