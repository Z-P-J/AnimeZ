import media from '@ohos.multimedia.media';
import IPlayer from './IPlayer';
import EpisodeInfo from '../entity/EpisodeInfo';

export enum PlayerStatus {
  IDLE = 0,
  INITIALIZED = 1,
  PREPARED = 2,
  PLAY = 4,
  PAUSE = 5,
  STOP = 6,
  ERROR = 7,
  DONE = 8
}

export enum VideoFit {
  Contain,
  Cover,
  Fill,
  Fit_16_9,
  Fit_4_3,
  Fit_1_1,
}

// TODO 优化监听回调，改为on('xxxx', (x) => void)
export interface PlayerListener {

  onStatusChanged(status: number)

//  onEpisodeChanged(episode: EpisodeInfo)

  onEpisodeChanged(episodeList: EpisodeInfo[], episodeIndex: number)

  onVideoSpeedChanged(videoSpeed: PlaybackSpeed)

  onFullScreenChanged(isFullScreen: boolean)

  onVideoFitChanged(videoFit: VideoFit)

  onVideoSizeChange(w: number, h: number)

  onProgressChange(totalTime: number, currentTime: number)

  onBuffering(type: media.BufferingInfoType, value: number)

}

export default interface IPlayerManager {

  init(player: IPlayer)

//  setEpisode(episode: EpisodeInfo);

//  playEpisode(episode: EpisodeInfo): Promise<void>

//  getEpisode(): EpisodeInfo;

//  getEpisodeList(): EpisodeInfo[];

  playEpisodeList(episodeList: EpisodeInfo[], episodeIndex?: number): Promise<void>;

//  playEpisodeAt(episodeIndex: number): Promise<void>

//  setPlayerUrl(url: string);

  start(): Promise<void>;

  pause(): Promise<void>;

  stop(): Promise<void>;

  seekTo(value: number): Promise<void>;

  setSpeed(speed: PlaybackSpeed): Promise<void>;

  getSpeed(): PlaybackSpeed;

  isPlaying(): boolean;

  setVideoFit(videoFit: VideoFit);

  setStatus(status: PlayerStatus);

  getStatus(): PlayerStatus;

  isPrepared(): boolean;

  getDuration(): number;

  getCurrentPosition(): number;

  addListener(listener: PlayerListener);

  removeListener(listener: PlayerListener);

  destroy();

  isFullScreen();

  enterFullScreen();

  exitFullScreen();

  onVideoSizeChanged(width: number, height: number)

  notifyDuration(duration: number);

  notifyCurrentTime(currentTime: number);

  notifyDuration(duration: number);

  notifyTime(duration: number, currentTime: number);

  notifyBuffering(type: media.BufferingInfoType, value: number)

}