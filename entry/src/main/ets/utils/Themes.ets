import SystemBarUtils from './SystemBarUtils';
import Logger from './Logger';
import DataStore from './DataStore';

/**
 * 主题接口
 */
export interface Theme {
  isDarkTheme: boolean,
  primary_color: Resource
  background_color: Resource
  background_color_accent: Resource
  background_color_dark: Resource

  color_text_major: Resource
  color_text_normal: Resource
  color_text_minor: Resource

  statusBarColor: string
  statusBarContentColor: string
  navigationBarColor: string
  navigationBarContentColor: string

  initBar();
}

/**
 * 默认主题
 */
const default_theme: Theme = {
  isDarkTheme: false,
  primary_color: $r('app.color.primary_color'),
  background_color: $r('app.color.background_color'),
  background_color_accent: $r('app.color.background_color_accent'),
  background_color_dark: $r('app.color.background_color_dark'),

  color_text_major: $r('app.color.color_text_major'),
  color_text_normal: $r('app.color.color_text_normal'),
  color_text_minor: $r('app.color.color_text_minor'),

  statusBarColor: '#00000000',
  statusBarContentColor: '#000000',
  navigationBarColor: '#00000000',
  navigationBarContentColor: '#000000',

  initBar() {
    SystemBarUtils.setWindowSystemBarProperties({
      statusBarColor: this.statusBarColor,
      statusBarContentColor: this.statusBarContentColor,
      navigationBarColor: this.navigationBarColor,
      navigationBarContentColor: this.navigationBarContentColor
    })
  }
}

/**
 * 暗色主题
 */
const night_theme: Theme = {
  isDarkTheme: true,
  primary_color: $r('app.color.primary_color'),
  background_color: $r('app.color.background_color_night'),
  background_color_accent: $r('app.color.background_color_accent_night'),
  background_color_dark: $r('app.color.background_color_dark_night'),

  color_text_major: $r('app.color.color_text_major_night'),
  color_text_normal: $r('app.color.color_text_normal_night'),
  color_text_minor: $r('app.color.color_text_minor_night'),

  statusBarColor: '#00000000',
  statusBarContentColor: '#ffffff',
  navigationBarColor: '#00000000',
  navigationBarContentColor: '#ffffff',

  initBar() {
    SystemBarUtils.setWindowSystemBarProperties({
      statusBarColor: this.statusBarColor,
      statusBarContentColor: this.statusBarContentColor,
      navigationBarColor: this.navigationBarColor,
      navigationBarContentColor: this.navigationBarContentColor
    })
  }
}

export const KEY_THEME_ID = 'key_theme_id'

/**
 * 获取主题
 * @param theme 当前主题
 */
export function getTheme(theme: number): Theme {
  if (theme == 0) {
    return default_theme
  } else {
    return night_theme
  }
}

export function getCurrentTheme(): number {
  return DataStore.getInt(KEY_THEME_ID, 0);
}

/**
 * 设置主题
 * @param theme 主题id
 */
export function setTheme(theme: number) {
  DataStore.set(KEY_THEME_ID, theme)
}