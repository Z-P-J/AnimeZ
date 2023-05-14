import Logger from './Logger';
import window from '@ohos.window';

export default class SystemBarUtils {

  /**
   * 设置状态栏和导航栏颜色等属性
   * @param systemBarProperties
   */
  static setWindowSystemBarProperties(systemBarProperties: window.SystemBarProperties) {
    window.getLastWindow(getContext(this), (err, win) => {
      Logger.e(this, 'setWindowSystemBarProperties win=' + JSON.stringify(win) + ' err=' + JSON.stringify(err))
      if (win) {
        // 透明状态栏和导航栏
        win.setWindowSystemBarProperties(systemBarProperties, null);
      }
    })
  }

}