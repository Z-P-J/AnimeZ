import media from '@ohos.multimedia.media';
import IPlayer from './IPlayer';
import { IJKMediaInfo } from './IjkMediaInfo';
import { IjkMediaPlayer } from './IjkMediaPlayer';
import { VideoPlayerController } from './VideoPlayerController';
import IPlayerManager, { PlayerListener, PlayerStatus, VideoFit } from './IPlayerManager';
import EpisodeInfo from '../entity/EpisodeInfo';
import DisplayUtils from '../utils/DisplayUtils';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import Logger from '../utils/Logger';

const DEFAULT_ASPECT = 1.9

/**
 * 视频播放器，封装IjkPlayer
 * TODO 网络视频还存在加载缓慢的问题
 */
@Component
export struct IjkVideoPlayer {
  private readonly ijkPlayer: IjkMediaPlayer = new IjkMediaPlayer()
  @State videoAspRatio: number = DEFAULT_ASPECT
  @State aspRatio: number = DEFAULT_ASPECT
  @State playStatus: number = PlayerStatus.IDLE
  @State playerStatus: PlayerStatus = PlayerStatus.IDLE
  @State isFullScreen: boolean = false
  private readonly componentController: XComponentController = new XComponentController()
  private playerManager: IPlayerManager = null;
  private immersionStatusBar: boolean = false
  private updateProgressTimer: number = -1
  private lastTime: number;
  private readonly player: IPlayer = {
    setDataSource: async (url: string) => {
      this.ijkPlayer.setDataSource(url)
      this.playerManager.setStatus(PlayerStatus.INITIALIZED)
    },
    start: async () => {
      this.ijkPlayer.start()
      this.playerManager.setStatus(PlayerStatus.PLAY)
    },
    prepare: async () => {
      this.ijkPlayer.prepareAsync()
    },
    pause: async () => {
      this.ijkPlayer.pause()
      this.playerManager.setStatus(PlayerStatus.PAUSE)
    },
    stop: async () => {
      this.ijkPlayer.stop()
      this.playerManager.setStatus(PlayerStatus.STOP)
    },
    reset: async () => {
      this.ijkPlayer.reset()
      this.playerManager.setStatus(PlayerStatus.IDLE)
    },
    release: async () => {
      this.ijkPlayer.release()
    },
    seekTo: async (value: number) => {
      this.ijkPlayer.seekTo(value)
    },
    setSpeed: async (speed: PlaybackSpeed) => {
      switch (speed) {
        case PlaybackSpeed.Speed_Forward_0_75_X:
          this.ijkPlayer.setSpeed('0.75')
          break
        case PlaybackSpeed.Speed_Forward_1_00_X:
          this.ijkPlayer.setSpeed('1.00')
          break
        case PlaybackSpeed.Speed_Forward_1_25_X:
          this.ijkPlayer.setSpeed('1.25')
          break
        case PlaybackSpeed.Speed_Forward_1_75_X:
          this.ijkPlayer.setSpeed('1.75')
          break
        case PlaybackSpeed.Speed_Forward_2_00_X:
          this.ijkPlayer.setSpeed('2.00')
          break
      }
    }
  }

  /**
   * 播放器监听回调
   */
  private readonly playerListener: PlayerListener = {
    onStatusChanged: (status: number) => {
      this.playerStatus = status

      if (status == PlayerStatus.PLAY) {
        this.startProgress()
      } else {
        this.stopProgress()
      }
    },
    onEpisodeChanged: (episodeList: EpisodeInfo[], episodeIndex: number) => {
    },
    onVideoSpeedChanged: (videoSpeed: PlaybackSpeed) => {
    },
    onVideoFitChanged: (videoFit: VideoFit) => {
    },
    onFullScreenChanged: (isFullScreen: boolean) => {
      this.isFullScreen = isFullScreen
      animateTo({
        duration: 360,
        curve: Curve.Smooth,
        iterations: 1,
        playMode: PlayMode.Normal
      }, () => {
        if (isFullScreen) {
          this.aspRatio = DisplayUtils.getRealScreenHWRatio()
        } else {
          this.aspRatio = Math.min(DEFAULT_ASPECT, this.videoAspRatio);
        }
      })
    },
    onVideoSizeChange: (w: number, h: number) => {
      animateTo({
        duration: 360,
        curve: Curve.Smooth,
        iterations: 1,
        playMode: PlayMode.Normal
      }, () => {
        this.videoAspRatio = w / h
        if (this.isFullScreen) {
          this.aspRatio = DisplayUtils.getRealScreenHWRatio()
        } else {
          this.aspRatio = Math.min(DEFAULT_ASPECT, this.videoAspRatio);
        }
        Logger.e(this, 'VideoSizeChange w=' + w + ' h=' + h + ' videoAspRatio=' + this.videoAspRatio + ' aspRatio=' + this.aspRatio)
      })
    },
    onProgressChange: (totalTime: number, currentTime: number) => {
    },
    onBuffering: (type: media.BufferingInfoType, value: number) => {
    }
  }

  aboutToAppear() {
    if (this.playerManager) {
      this.playerManager.addListener(this.playerListener)
    } else {
      throw new Error('You must set playerManager firstly!')
    }
  }

  aboutToDisappear() {
    this.playerManager.removeListener(this.playerListener)
  }

  build() {
    Column() {
      if (!this.isFullScreen && this.immersionStatusBar) {
        ImmersionBarSpace().backgroundColor(Color.Black)
      }
      Stack({ alignContent: Alignment.Center }) {
        XComponent({
          id: '' + new Date().getTime(),
          type: 'surface',
          libraryname: 'ijkplayer_napi',
          controller: this.componentController
        })
          .onLoad((context) => {
            Logger.e(this, 'XComponent onLoad')

            this.initIjk(context)
            this.playerManager.init(this.player)
          })
          .onDestroy(() => {
            Logger.e(this, 'XComponent onDestroy')
          })
          .width('100%')
          .aspectRatio(this.videoAspRatio)

        VideoPlayerController({ playerManager: this.playerManager })
          .width('100%')
          .height('100%')
      }
      .backgroundColor(Color.Black)
      .width('100%')
      .aspectRatio(this.aspRatio)
    }
    .width('100%')
  }

  initIjk(context: object) {
    Logger.e(this, 'init context=' + context)
    //设置XComponent回调的context
    this.ijkPlayer.setContext(context);
    this.ijkPlayer.reset();

    //设置debug模式
    this.ijkPlayer.setDebug(false);
    //初始化配置
    this.ijkPlayer.native_setup();
    // 屏幕常亮
    this.ijkPlayer.setScreenOnWhilePlaying(true);

    this.initPlayer()
    this.initOptions()
  }

  private initPlayer() {
    this.ijkPlayer.setOnVideoSizeChangedListener({
      onVideoSizeChanged: (width: number, height: number, sar_num: number, sar_den: number) => {
        if (typeof width == 'string') {
          width = parseInt(width)
        }
        if (typeof height == 'string') {
          height = parseInt(height)
        }
        this.playerManager.onVideoSizeChanged(width, height)
      }
    })

    this.ijkPlayer.setOnBufferingUpdateListener({
      onBufferingUpdate: (percent: number) => {
        Logger.e(this, 'onBufferingUpdate p=' + percent)
      }
    })

    this.ijkPlayer.setOnCompletionListener({
      onCompletion: () => {
        Logger.e(this, 'onCompletion')
        this.playerManager.setStatus(PlayerStatus.DONE)
      }
    })

    this.ijkPlayer.setOnSeekCompleteListener({
      onSeekComplete: () => {
        Logger.e(this, 'onSeekComplete')
      }
    })


    this.ijkPlayer.setOnErrorListener({
      onError: (what: number, extra: number) => {
        Logger.e(this, 'onError what=' + what + " extra=" + extra)
        this.playerManager.setStatus(PlayerStatus.ERROR)
      }
    })

    this.ijkPlayer.setOnPreparedListener({
      onPrepared: () => {
        Logger.e(this, 'onPrepared')
        this.playerManager.setStatus(PlayerStatus.PREPARED)
      }
    })

    this.ijkPlayer.setOnInfoListener({
      onInfo: (what: number, extra: number) => {
        this.onInfo(what, extra)
      }
    })

    this.ijkPlayer.setMessageListener()
  }

  private initOptions() {
    // 不用MediaCodec编解码
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", '1');
    // 不用opensles编解码
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "opensles", '0');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "overlay-format", '842225234');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", '1');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", '0');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "http-detect-range-support", '0');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "timeout", '10000000');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "reconnect", '1');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", '48');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", '0');
    this.ijkPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_clear", '1');
  }

  protected onInfo(what: number, extra: number) {
    Logger.e(this, "OnInfoListener-->go:" + what + "===" + extra);
    if (what == IJKMediaInfo.MEDIA_INFO_BUFFERING_START) {
      this.playerManager.notifyBuffering(media.BufferingInfoType.BUFFERING_START, 0)
    } else if (what == IJKMediaInfo.MEDIA_INFO_BUFFERING_END) {
      this.playerManager.notifyBuffering(media.BufferingInfoType.BUFFERING_END, 0)
    } else if (what == IJKMediaInfo.MEDIA_INFO_VIDEO_RENDERING_START) {
      this.ijkPlayer.start()
      this.playerManager.setStatus(PlayerStatus.PLAY)
    }
  }

  /**
   * 每隔1000ms通知播放进度
   */
  private startProgress() {
    this.stopProgress()
    this.updateProgressTimer = setInterval(() => {
      if (this.updateProgressTimer < 0) {
        return
      }
      let totalTime = this.ijkPlayer.getDuration()
      let currentTime = this.ijkPlayer.getCurrentPosition()
      if (this.lastTime == currentTime) {
        return
      }
      this.lastTime = currentTime
      this.playerManager.notifyTime(totalTime, currentTime)
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