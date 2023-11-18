
// 默认动画时长
export const DEFAULT_DURATION = 360

// 默认动画曲线
export const DEFAULT_CURVE = 'M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1'

// 进场动画配置
export const OPTIONS_TRANSITION_PUSH = {
  type: RouteType.Push,
  duration: DEFAULT_DURATION,
  curve: DEFAULT_CURVE
}

// 退场动画配置
export const OPTIONS_TRANSITION_POP = {
  type: RouteType.Pop,
  duration: DEFAULT_DURATION,
  curve: DEFAULT_CURVE
}