import Foundation

struct LiquidGlassSliderValue {
  let reportedValue: Float
  let displayValue: Float
}

struct LiquidGlassSliderValueCoordinator {
  let minimumValue: Float
  let maximumValue: Float
  let step: Float?

  func value(for rawValue: Float, isTracking: Bool) -> LiquidGlassSliderValue {
    let clampedValue = clamped(rawValue)
    let reportedValue = quantized(clampedValue)
    let displayValue = isTracking ? clampedValue : reportedValue

    return LiquidGlassSliderValue(
      reportedValue: reportedValue,
      displayValue: displayValue
    )
  }

  private func quantized(_ value: Float) -> Float {
    guard let step, step > 0 else {
      return value
    }

    let steps = round((value - minimumValue) / step)
    return clamped(minimumValue + steps * step)
  }

  private func clamped(_ value: Float) -> Float {
    return min(max(value, minimumValue), maximumValue)
  }
}
