import Flutter
import UIKit

final class LiquidGlassSegmentedControlPlatformView: NSObject, FlutterPlatformView {
  private var control = UISegmentedControl()
  private let channel: FlutterMethodChannel
  private let container = UIView()

  init(viewId: Int64, arguments: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/segmented_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    container.backgroundColor = .clear
    installControl(arguments: arguments)
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
    return container
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setConfiguration":
      installControl(arguments: call.arguments)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func installControl(arguments: Any?) {
    control.removeFromSuperview()

    let map = arguments as? [String: Any] ?? [:]
    let segments = map["segments"] as? [String] ?? []
    let selectedIndex = map["selectedIndex"] as? Int ?? 0
    let nextControl = UISegmentedControl(items: segments)

    if segments.isEmpty {
      nextControl.selectedSegmentIndex = UISegmentedControl.noSegment
    } else {
      nextControl.selectedSegmentIndex = min(max(selectedIndex, 0), segments.count - 1)
    }
    nextControl.isEnabled = map["enabled"] as? Bool ?? true
    nextControl.selectedSegmentTintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["tintColor"] as? NSNumber
    ).withAlphaComponent(0.22)
    nextControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    nextControl.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(nextControl)
    NSLayoutConstraint.activate([
      nextControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      nextControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      nextControl.topAnchor.constraint(equalTo: container.topAnchor),
      nextControl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    control = nextControl
  }

  @objc private func valueChanged() {
    channel.invokeMethod("onChanged", arguments: control.selectedSegmentIndex)
  }
}
