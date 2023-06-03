/**
 * 配置page转场动画
 */
export default class TransitionHelper {
  /**
   * 动画时长
   */
  static DURATION = 360

  /**
   * 动画曲线
   */
  static CURVE = 'M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1'

  /**
   * 进场动画配置
   */
  static OPTIONS_TRANSITION_PUSH = {
    type: RouteType.Push,
    duration: TransitionHelper.DURATION,
    curve: TransitionHelper.CURVE
  }

  /**
   * 退场动画配置
   */
  static OPTIONS_TRANSITION_POP = {
    type: RouteType.Pop,
    duration: TransitionHelper.DURATION,
    curve: TransitionHelper.CURVE
  }
}