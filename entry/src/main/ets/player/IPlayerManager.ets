import EpisodeInfo from '../entity/EpisodeInfo';

export enum PlayerStatus {
  INIT = 0,
  BUFFERING = 1,
  PLAY = 2,
  PAUSE = 3,
  STOP = 4,
  ERROR = 5,
  DONE = 6
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

  //    onStatusChanged(status: number): void;

  onStatusChanged(status: number)

  onEpisodeChanged(episode: EpisodeInfo)

  onVideoSpeedChanged(videoSpeed: PlaybackSpeed)

  onFullScreenChanged(isFullScreen: boolean)

  onVideoFitChanged(videoFit: VideoFit)

  onVideoSizeChange(w: number, h: number)

  onProgressChange(totalTime: number, currentTime: number)

}

export default interface IPlayerManager {

  init(context: object)

  setEpisode(episode: EpisodeInfo);

  getEpisode(): EpisodeInfo;

  getEpisodeList(): EpisodeInfo[];

  setPlayerUrl(url: string);

  start();

  pause();

  stop();

  seekTo(value: number);

  setSpeed(speed: PlaybackSpeed);

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

}