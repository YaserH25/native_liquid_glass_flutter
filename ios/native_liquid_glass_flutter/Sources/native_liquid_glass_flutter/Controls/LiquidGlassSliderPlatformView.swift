import Flutter
import UIKit

final class LiquidGlassSliderPlatformView: NSObject, FlutterPlatformView {
  private let slider = UISlider()
  private let channel: FlutterMethodChannel
  private var step: Float?

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/slider_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    configure(arguments: arguments, animated: false)
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    slider.addTarget(
      self,
      action: #selector(changeEnded),
      for: [.touchUpInside, .touchUpOutside, .touchCancel]
    )
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return slider
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setConfiguration":
      configure(arguments: call.arguments, animated: true)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(arguments: Any?, animated: Bool) {
    let map = arguments as? [String: Any] ?? [:]
    let value = (map["value"] as? NSNumber)?.floatValue ?? slider.value
    slider.minimumValue = (map["min"] as? NSNumber)?.floatValue ?? 0
    slider.maximumValue = (map["max"] as? NSNumber)?.floatValue ?? 1
    slider.isEnabled = map["enabled"] as? Bool ?? true
    step = (map["step"] as? NSNumber)?.floatValue
    slider.minimumTrackTintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["activeColor"] as? NSNumber
    )

    if let inactiveColor = map["inactiveColor"] as? NSNumber {
      slider.maximumTrackTintColor = LiquidGlassSurfaceConfiguration.color(
        from: inactiveColor
      )
    }

    slider.setValue(quantized(value: value, arguments: map), animated: animated)
  }

  @objc private func valueChanged() {
    let value = quantized(value: slider.value)
    if value != slider.value {
      slider.setValue(value, animated: false)
    }
    channel.invokeMethod("onChanged", arguments: Double(value))
  }

  @objc private func changeEnded() {
    channel.invokeMethod("onChangeEnd", arguments: Double(slider.value))
  }

  private func quantized(value: Float, arguments: [String: Any]? = nil) -> Float {
    let currentStep = (arguments?["step"] as? NSNumber)?.floatValue ?? step
    guard let currentStep = currentStep, currentStep > 0 else {
      return min(max(value, slider.minimumValue), slider.maximumValue)
    }

    let steps = round((value - slider.minimumValue) / currentStep)
    let quantized = slider.minimumValue + steps * currentStep
    return min(max(quantized, slider.minimumValue), slider.maximumValue)
  }
}
