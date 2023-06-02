import Logger from '../utils/Logger';
/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { OnPreparedListener } from "@ohos/ijkplayer";
import { OnCompletionListener } from "@ohos/ijkplayer";
import { OnVideoSizeChangedListener } from "@ohos/ijkplayer";
import { OnBufferingUpdateListener } from "@ohos/ijkplayer";
import { OnErrorListener } from "@ohos/ijkplayer";
import { OnInfoListener } from "@ohos/ijkplayer";
import { OnSeekCompleteListener } from "@ohos/ijkplayer";
import { OnTimedTextListener } from "@ohos/ijkplayer";
import { MessageType } from "@ohos/ijkplayer";
import { PropertiesType } from "@ohos/ijkplayer";
import { LogUtils } from "@ohos/ijkplayer";
import window from '@ohos.window';

/**
 * 去除原始代码中的单例
 */
export class IjkMediaPlayer {

  public static OPT_CATEGORY_FORMAT: string = "1";
  public static OPT_CATEGORY_CODEC: string = "2";
  public static OPT_CATEGORY_SWS: string = "3";
  public static OPT_CATEGORY_PLAYER: string = "4";
  private mVideoWidth: number = 0;
  private mVideoHeight: number = 0;
  private mVideoSarNum: number = 0;
  private mVideoSarDen: number = 0;
  private mOnVideoSizeChangedListener: OnVideoSizeChangedListener;
  private mOnPreparedListener: OnPreparedListener;
  private mOnCompletionListener: OnCompletionListener;
  private mOnBufferingUpdateListener: OnBufferingUpdateListener;
  private mOnErrorListener: OnErrorListener;
  private mOnInfoListener: OnInfoListener;
  private mOnSeekCompleteListener: OnSeekCompleteListener;
  private mOnTimedTextListener: OnTimedTextListener;
  private ijkplayer_napi = null;

  isInit(): boolean {
    return this.ijkplayer_napi ? true : false
  }

  setContext(context: object) {
    this.ijkplayer_napi = context;
  }

  setDebug(open: boolean) {
    LogUtils.getInstance().setLogSwitch(open);
    if (open) {
      this.ijkplayer_napi._nativeOpenlog();
    }
  }

  setDataSource(url: string) {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._setDataSource(url);
    }
  }

  setOption(category: string, key: string, value: string) {
    this.ijkplayer_napi._setOption(category, key, value);
  }

  setOptionLong(category: string, key: string, value: string) {
    this.ijkplayer_napi._setOptionLong(category, key, value);
  }

  prepareAsync() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._prepareAsync();
    }
  }

  start() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._start();
    }
  }

  stop() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._stop();
    }
  }

  pause() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._pause();
    }
  }

  reset() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._reset();
    }
  }

  release() {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._release();
    }
  }

  seekTo(msec: string) {
    if (this.ijkplayer_napi) {
      this.ijkplayer_napi._seekTo(msec);
    }
  }

  setScreenOnWhilePlaying(on: boolean) {
    window.getTopWindow(getContext(this), (err, data) => {
      data.setKeepScreenOn(on);
    });
  }

  setSpeed(speed: string) {
    this._setPropertyFloat(PropertiesType.FFP_PROP_FLOAT_PLAYBACK_RATE, speed);
  }

  getSpeed(): number {
    return this._getPropertyFloat(PropertiesType.FFP_PROP_FLOAT_PLAYBACK_RATE, "0");
  }

  isPlaying(): boolean {
    if (this.ijkplayer_napi) {
      return this.ijkplayer_napi._isPlaying();
    }
    return false;
  }

  setOnVideoSizeChangedListener(listener: OnVideoSizeChangedListener) {
    this.mOnVideoSizeChangedListener = listener;
  }

  setOnPreparedListener(listener: OnPreparedListener) {
    this.mOnPreparedListener = listener;
  }

  setOnCompletionListener(listener: OnCompletionListener) {
    this.mOnCompletionListener = listener;
  }

  setOnInfoListener(listener: OnInfoListener) {
    this.mOnInfoListener = listener;
  }

  setOnErrorListener(listener: OnErrorListener) {
    this.mOnErrorListener = listener;
  }

  setOnBufferingUpdateListener(listener: OnBufferingUpdateListener) {
    this.mOnBufferingUpdateListener = listener;
  }

  setOnSeekCompleteListener(listener: OnSeekCompleteListener) {
    this.mOnSeekCompleteListener = listener;
  }

  setOnTimedTextListener(listener: OnTimedTextListener) {
    this.mOnTimedTextListener = listener;
  }

  setMessageListener() {
    LogUtils.getInstance().LOGI("setMessageListener start");
    let that = this;
    let onVideoSizeChangedListener = this.mOnVideoSizeChangedListener;
    let onPreparedListener = this.mOnPreparedListener;
    let onCompletionListener = this.mOnCompletionListener;
    let onBufferingUpdateListener = this.mOnBufferingUpdateListener;
    let onErrorListener = this.mOnErrorListener;
    let onInfoListener = this.mOnInfoListener;
    let onSeekCompleteListener = this.mOnSeekCompleteListener;
    let onTimedTextListener = this.mOnTimedTextListener;
    let messageCallBack = function (what, arg1, arg2, obj) {
      LogUtils.getInstance()
        .LOGI("setMessageListener callback what:" + what + ", arg1:" + arg1 + ",arg2:" + arg2 + ",obj:" + obj);
      Logger.e(this, "setMessageListener callback what:" + what + ", arg1:" + arg1 + ",arg2:" + arg2 + ",obj:" + obj)
      if (what == MessageType.MEDIA_PREPARED) {
        onPreparedListener.onPrepared();
      }
      if (what == MessageType.MEDIA_SET_VIDEO_SAR) {
        if (arg1 != undefined && arg2 != undefined) {
          that.mVideoSarNum = arg1;
          that.mVideoSarDen = arg2;
        }
      }
      if (what == MessageType.MEDIA_SET_VIDEO_SIZE && onVideoSizeChangedListener != null) {
        onVideoSizeChangedListener.onVideoSizeChanged(arg1, arg2, that.mVideoSarNum, that.mVideoSarDen);
        if (arg1 != 0 && arg2 != 0) {
          that.mVideoWidth = arg1;
          that.mVideoHeight = arg2;
        }
      }

      if (what == MessageType.MEDIA_PLAYBACK_COMPLETE && onCompletionListener != null) {
        onCompletionListener.onCompletion();
      }

      if (what == MessageType.MEDIA_BUFFERING_UPDATE && onBufferingUpdateListener != null) {
        let bufferPosition = arg1;
        if (bufferPosition < 0) {
          bufferPosition = 0;
        }
        let percent = 0;
        let duration = that.ijkplayer_napi._getDuration();
        if (duration > 0) {
          percent = bufferPosition * 100 / duration;
        }
        if (percent >= 100) {
          percent = 100;
        }
        onBufferingUpdateListener.onBufferingUpdate(percent);
      }

      if (what == MessageType.MEDIA_ERROR && onErrorListener != null) {
        onErrorListener.onError(arg1, arg2);
      }
      if (what == MessageType.MEDIA_INFO && onInfoListener != null) {
        onInfoListener.onInfo(arg1, arg2);
      }
      if (what == MessageType.MEDIA_SEEK_COMPLETE && onSeekCompleteListener != null) {
        onSeekCompleteListener.onSeekComplete();
      }
      if (what == MessageType.MEDIA_TIMED_TEXT && onTimedTextListener != null) {
        onTimedTextListener.onTimedText(obj);
      }
    };
    this.ijkplayer_napi._setMessageListener(messageCallBack);
  }

  getVideoWidth(): number {
    return this.mVideoWidth;
  }

  getVideoHeight(): number {
    return this.mVideoHeight;
  }

  getVideoSarNum(): number {
    return this.mVideoSarNum;
  }

  getVideoSarDen(): number {
    return this.mVideoSarDen;
  }

  getDuration(): number {
    return this.ijkplayer_napi._getDuration();
  }

  getCurrentPosition(): number {
    return this.ijkplayer_napi._getCurrentPosition();
  }

  getAudioSessionId(): number {
    return this.ijkplayer_napi._getAudioSessionId();
  }

  private _setPropertyFloat(property: string, value: string) {
    this.ijkplayer_napi._setPropertyFloat(property, value);
  }

  private _getPropertyFloat(property: string, value: string): number {
    return this.ijkplayer_napi._getPropertyFloat(property, value);
  }

  private _setPropertyLong(property: string, value: string) {
    this.ijkplayer_napi._setPropertyLong(property, value);
  }

  private _getPropertyLong(property: string, value: string): number {
    return this.ijkplayer_napi._getPropertyLong(property, value);
  }

  setVolume(leftVolume: string, rightVolume: string) {
    this.ijkplayer_napi._setVolume(leftVolume, rightVolume);
  }

  setLoopCount(looping: boolean) {
    let loopCount = looping ? "0" : "1";
    this.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "loop", loopCount);
    this.ijkplayer_napi._setLoopCount(loopCount);
  }

  isLooping(): boolean {
    let loopCount = this.ijkplayer_napi._getLoopCount();
    return loopCount != 1;
  }

  selectTrack(track: string) {
    this._setStreamSelected(track, "true");
  }

  deselectTrack(track: string) {
    this._setStreamSelected(track, "false");
  }

  private _setStreamSelected(stream: string, select: string) {
    this.ijkplayer_napi._setStreamSelected(stream, select);
  }

  getVideoDecoder(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_VIDEO_DECODER, PropertiesType.FFP_PROPV_DECODER_UNKNOWN);
  }

  getVideoOutputFramesPerSecond(): number {
    return this._getPropertyFloat(PropertiesType.PROP_FLOAT_VIDEO_OUTPUT_FRAMES_PER_SECOND, "0");
  }

  getVideoDecodeFramesPerSecond(): number {
    return this._getPropertyFloat(PropertiesType.PROP_FLOAT_VIDEO_DECODE_FRAMES_PER_SECOND, "0");
  }

  getVideoCachedDuration(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_VIDEO_CACHED_DURATION, "0");
  }

  getAudioCachedDuration(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_AUDIO_CACHED_DURATION, "0");
  }

  getVideoCachedBytes(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_VIDEO_CACHED_BYTES, "0");
  }

  getAudioCachedBytes(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_AUDIO_CACHED_BYTES, "0");
  }

  getVideoCachedPackets(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_VIDEO_CACHED_PACKETS, "0");
  }

  getAudioCachedPackets(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_AUDIO_CACHED_PACKETS, "0");
  }

  getAsyncStatisticBufBackwards(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_ASYNC_STATISTIC_BUF_BACKWARDS, "0");
  }

  getAsyncStatisticBufForwards(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_ASYNC_STATISTIC_BUF_FORWARDS, "0");
  }

  getAsyncStatisticBufCapacity(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_ASYNC_STATISTIC_BUF_CAPACITY, "0");
  }

  getTrafficStatisticByteCount(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_TRAFFIC_STATISTIC_BYTE_COUNT, "0");
  }

  getCacheStatisticPhysicalPos(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_CACHE_STATISTIC_PHYSICAL_POS, "0");
  }

  getCacheStatisticFileForwards(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_CACHE_STATISTIC_FILE_FORWARDS, "0");
  }

  getCacheStatisticFilePos(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_CACHE_STATISTIC_FILE_POS, "0");
  }

  getCacheStatisticCountBytes(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_CACHE_STATISTIC_COUNT_BYTES, "0");
  }

  getFileSize(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_LOGICAL_FILE_SIZE, "0");
  }

  getBitRate(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_BIT_RATE, "0");
  }

  getTcpSpeed(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_TCP_SPEED, "0");
  }

  getSeekLoadDuration(): number {
    return this._getPropertyLong(PropertiesType.FFP_PROP_INT64_LATEST_SEEK_LOAD_DURATION, "0");
  }

  getDropFrameRate(): number {
    return this._getPropertyFloat(PropertiesType.FFP_PROP_FLOAT_DROP_FRAME_RATE, "0");
  }

  setCacheShare(share: string) {
    this._setPropertyLong(PropertiesType.FFP_PROP_INT64_SHARE_CACHE_DATA, share);
  }

  private _getVideoCodecInfo(): string {
    return this.ijkplayer_napi._getVideoCodecInfo();
  }

  private _getAudioCodecInfo(): string {
    return this.ijkplayer_napi._getAudioCodecInfo();
  }

  private _getMediaMeta(): string {
    return this.ijkplayer_napi._getMediaMeta();
  }

  getMediaInfo(): object {
    let mAudioDecoder = this._getAudioCodecInfo();
    let mVideoDecoder = this._getVideoCodecInfo();
    let mMeta = this._getMediaMeta();
    let mediaInfo = { audioDecoder: mAudioDecoder, videoDecoder: mVideoDecoder, meta: mMeta };
    return mediaInfo;
  }

  native_setup() {
    this.ijkplayer_napi._native_setup();
  }
}

