import Flutter
import UIKit

struct LiquidGlassSliderConfiguration {
  let isContinuous: Bool
  let minimumSymbol: String?
  let maximumSymbol: String?

  init(arguments: [String: Any]) {
    self.isContinuous = Self.bool(from: arguments["isContinuous"]) ?? true
    self.minimumSymbol = arguments["minimumSymbol"] as? String
    self.maximumSymbol = arguments["maximumSymbol"] as? String
  }

  private static func bool(from value: Any?) -> Bool? {
    if let bool = value as? Bool {
      return bool
    }
    if let number = value as? NSNumber {
      return number.boolValue
    }
    return nil
  }
}

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
    let configuration = LiquidGlassSliderConfiguration(arguments: map)
    let environment = LiquidGlassEnvironmentConfiguration(arguments: map)
    let value = (map["value"] as? NSNumber)?.floatValue ?? slider.value
    slider.applyLiquidGlassEnvironment(environment)
    slider.minimumValue = (map["min"] as? NSNumber)?.floatValue ?? 0
    slider.maximumValue = (map["max"] as? NSNumber)?.floatValue ?? 1
    slider.isEnabled = map["enabled"] as? Bool ?? true
    slider.isContinuous = configuration.isContinuous
    slider.minimumValueImage = Self.image(systemName: configuration.minimumSymbol)
    slider.maximumValueImage = Self.image(systemName: configuration.maximumSymbol)
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
    if slider.isContinuous {
      channel.invokeMethod(
        "onChanged",
        arguments: Double(sliderValue.reportedValue)
      )
    }
  }

  @objc private func changeEnded() {
    let sliderValue = coordinator.value(for: slider.value, isTracking: false)
    if sliderValue.displayValue != slider.value {
      slider.setValue(sliderValue.displayValue, animated: false)
    }
    if !slider.isContinuous {
      channel.invokeMethod(
        "onChanged",
        arguments: Double(sliderValue.reportedValue)
      )
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

  private static func image(systemName: String?) -> UIImage? {
    guard let systemName, !systemName.isEmpty else {
      return nil
    }
    return UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
  }
}
