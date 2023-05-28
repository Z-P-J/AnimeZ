import DataStore from './DataStore';


export default class Settings {
  static KEY_AUTO_PLAY_NEXT_EPISODE = 'key_auto_play_next_episode'
  static KEY_THEME_ID = 'key_theme_id'
  static KEY_HOMEPAGE_SOURCE = 'key_homepage_source'
  static KEY_AUTO_PLAY_ON_NO_WIFI = 'key_auto_play_on_no_wifi'
  static KEY_AUTO_RESUME_DOWNLOAD_ON_WIFI = 'key_auto_resume_download_on_wifi'
  static KEY_MAX_DOWNLOADING_COUNT = 'key_max_downloading_count'

  static isAutoPlayNextEpisode(): boolean {
    return DataStore.get(this.KEY_AUTO_PLAY_NEXT_EPISODE, true)
  }

  static isAutoPlayOnNoWifi(): boolean {
    return DataStore.get(this.KEY_AUTO_PLAY_ON_NO_WIFI, true)
  }

  static isAutoResumeDownloadOnWifi(): boolean {
    return DataStore.get(this.KEY_AUTO_PLAY_ON_NO_WIFI, false)
  }

  static getMaxDownloadingCount(): number {
    return DataStore.get(this.KEY_MAX_DOWNLOADING_COUNT, 3)
  }
}