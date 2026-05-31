import Flutter
import UIKit

final class LiquidGlassStepperPlatformView: NSObject, FlutterPlatformView {
  private let control = UIStepper()
  private let channel: FlutterMethodChannel

  init(viewId: Int64, arguments: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/stepper_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    configure(arguments: arguments)
    control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
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
    return control
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setConfiguration":
      configure(arguments: call.arguments)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]
    control.minimumValue = (map["min"] as? NSNumber)?.doubleValue ?? 0
    control.maximumValue = (map["max"] as? NSNumber)?.doubleValue ?? 100
    control.stepValue = (map["step"] as? NSNumber)?.doubleValue ?? 1
    control.value = (map["value"] as? NSNumber)?.doubleValue ?? 0
    control.isEnabled = map["enabled"] as? Bool ?? true
    control.tintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["tintColor"] as? NSNumber
    )
  }

  @objc private func valueChanged() {
    channel.invokeMethod("onChanged", arguments: control.value)
  }
}
