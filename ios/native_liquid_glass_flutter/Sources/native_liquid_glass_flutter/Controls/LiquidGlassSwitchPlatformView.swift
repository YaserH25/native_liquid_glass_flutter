import Flutter
import UIKit

final class LiquidGlassSwitchPlatformView: NSObject, FlutterPlatformView {
  private let control = UISwitch()
  private let channel: FlutterMethodChannel

  init(viewId: Int64, arguments: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/switch_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    configure(arguments: arguments, animated: false)
    control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return control
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
    control.isEnabled = map["enabled"] as? Bool ?? true
    control.onTintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["activeColor"] as? NSNumber
    )
    control.setOn(map["value"] as? Bool ?? false, animated: animated)
  }

  @objc private func valueChanged() {
    channel.invokeMethod("onChanged", arguments: control.isOn)
  }
}
