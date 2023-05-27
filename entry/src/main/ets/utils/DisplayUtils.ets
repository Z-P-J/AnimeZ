import display from '@ohos.display';

/**
 * 屏幕显示工具栏
 */
export default class DisplayUtils {


  /**
   * 获取Display对象
   */
  static getDefaultDisplay() {
    return display.getDefaultDisplaySync()
  }

  /**
   * 获取当前状态下屏幕宽度
   */
  static getScreenWidth() {
    let defaultDisplay = display.getDefaultDisplaySync()
    return defaultDisplay.width
  }

  /**
   * 获取当前状态下屏幕高度
   */
  static getScreenHeight() {
    let defaultDisplay = display.getDefaultDisplaySync()
    return defaultDisplay.height
  }

  /**
   * 获取屏幕宽高比
   */
  static getScreenRatio() {
    let defaultDisplay = display.getDefaultDisplaySync()
    return defaultDisplay.width / defaultDisplay.height
  }

  /**
   * 获取屏幕真实宽度，忽略屏幕方向
   */
  static getRealScreenWidth(): number {
    let defaultDisplay = display.getDefaultDisplaySync()
    if (defaultDisplay.rotation % 2 == 0) {
      return defaultDisplay.width
    } else {
      return defaultDisplay.height
    }
  }

  /**
   * 获取屏幕真实高度，忽略屏幕方向
   */
  static getRealScreenHeight(): number {
    let defaultDisplay = display.getDefaultDisplaySync()
    if (defaultDisplay.rotation % 2 == 0) {
      return defaultDisplay.height
    } else {
      return defaultDisplay.width
    }
  }

  /**
   * 获取真实屏幕宽高比，忽略屏幕方向
   */
  static getRealScreenWHRatio(): number {
    let defaultDisplay = display.getDefaultDisplaySync()
    if (defaultDisplay.rotation % 2 == 0) {
      return defaultDisplay.width / defaultDisplay.height
    } else {
      return defaultDisplay.height / defaultDisplay.width
    }
  }

  /**
   * 获取真实屏幕高宽比，忽略屏幕方向
   */
  static getRealScreenHWRatio(): number {
    let defaultDisplay = display.getDefaultDisplaySync()
    if (defaultDisplay.rotation % 2 == 0) {
      return defaultDisplay.height / defaultDisplay.width
    } else {
      return defaultDisplay.width / defaultDisplay.height
    }
  }

  /**
   * 获取屏幕dp值
   */
  static getDensityPixels(): number {
    let defaultDisplay = display.getDefaultDisplaySync()
    return defaultDisplay.densityPixels
  }

}