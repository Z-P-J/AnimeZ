import Logger from './Logger';
import window from '@ohos.window';

/**
 * 状态栏和导航栏工具类
 */
export default class SystemBarUtils {

  /**
   * 设置状态栏和导航栏颜色等属性
   * @param systemBarProperties
   */
  static setWindowSystemBarProperties(systemBarProperties: window.SystemBarProperties) {
    window.getLastWindow(getContext(this), (err, win) => {
      Logger.e(this, 'setWindowSystemBarProperties win=' + JSON.stringify(win) + ' err=' + JSON.stringify(err))
      try {
        if (win) {
          // 透明状态栏和导航栏
          win.setWindowSystemBarProperties(systemBarProperties, null);
        }
      } catch (e) {
        Logger.e(this, 'setWindowSystemBarProperties error! e=' + JSON.stringify(e))
      }
    })
  }
}