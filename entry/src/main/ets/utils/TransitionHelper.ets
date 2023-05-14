export default class TransitionHelper {
  static DURATION = 360
  static CURVE = 'M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1'
  static OPTIONS_TRANSITION_PUSH = {
    type: RouteType.Push,
    duration: TransitionHelper.DURATION,
    curve: TransitionHelper.CURVE
  }
  static OPTIONS_TRANSITION_POP = {
    type: RouteType.Pop,
    duration: TransitionHelper.DURATION,
    curve: TransitionHelper.CURVE
  }
}