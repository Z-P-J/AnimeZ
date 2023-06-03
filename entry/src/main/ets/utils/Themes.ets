
/**
 * 主题接口
 */
export interface Theme {
  primary_color: Resource
  background_color: Resource
  background_color_accent: Resource
  background_color_dark: Resource

  color_text_major: Resource
  color_text_normal: Resource
  color_text_minor: Resource
}

/**
 * 默认主题
 */
const default_theme = {
  primary_color: $r('app.color.primary_color'),
  background_color: $r('app.color.background_color'),
  background_color_accent: $r('app.color.background_color_accent'),
  background_color_dark: $r('app.color.background_color_dark'),

  color_text_major: $r('app.color.color_text_major'),
  color_text_normal: $r('app.color.color_text_normal'),
  color_text_minor: $r('app.color.color_text_minor')
}

/**
 * 暗色主题
 */
const night_theme = {
  primary_color: $r('app.color.primary_color'),
  background_color: $r('app.color.background_color_night'),
  background_color_accent: $r('app.color.background_color_accent_night'),
  background_color_dark: $r('app.color.background_color_dark_night'),

  color_text_major: $r('app.color.color_text_major_night'),
  color_text_normal: $r('app.color.color_text_normal_night'),
  color_text_minor: $r('app.color.color_text_minor_night')
}

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