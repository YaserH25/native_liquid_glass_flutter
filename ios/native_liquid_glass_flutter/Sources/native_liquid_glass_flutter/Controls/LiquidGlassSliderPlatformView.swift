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
    slider.isContinuous = true
    configure(arguments: arguments, animated: false)
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    slider.addTarget(
      self,
      action: #selector(changeEnded),
      for: [.touchUpInside, .touchUpOutside, .touchCancel]
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
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

    let sliderValue = coordinator.value(for: value, isTracking: false)
    slider.setValue(sliderValue.displayValue, animated: animated)
  }

  @objc private func valueChanged() {
    let sliderValue = coordinator.value(
      for: slider.value,
      isTracking: slider.isTracking
    )
    if sliderValue.displayValue != slider.value {
      slider.setValue(sliderValue.displayValue, animated: false)
    }
    channel.invokeMethod(
      "onChanged",
      arguments: Double(sliderValue.reportedValue)
    )
  }

  @objc private func changeEnded() {
    let sliderValue = coordinator.value(for: slider.value, isTracking: false)
    if sliderValue.displayValue != slider.value {
      slider.setValue(sliderValue.displayValue, animated: false)
    }
    channel.invokeMethod(
      "onChangeEnd",
      arguments: Double(sliderValue.reportedValue)
    )
  }

  private var coordinator: LiquidGlassSliderValueCoordinator {
    return LiquidGlassSliderValueCoordinator(
      minimumValue: slider.minimumValue,
      maximumValue: slider.maximumValue,
      step: step
    )
  }
}
