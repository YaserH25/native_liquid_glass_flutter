import Flutter
import SwiftUI
import UIKit

final class LiquidGlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let containerView: UIView
  private let channel: FlutterMethodChannel
  private var hostingController: UIViewController?

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = UIView(frame: frame)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/surface_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    containerView.backgroundColor = .clear
    configure(arguments: arguments)
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return containerView
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
    let configuration = LiquidGlassSurfaceConfiguration(arguments: arguments)

    containerView.layer.cornerRadius = configuration.cornerRadius
    containerView.layer.cornerCurve = .continuous
    containerView.clipsToBounds = true

    if #available(iOS 26.0, *) {
      updateLiquidGlass(configuration: configuration)
    } else {
      containerView.subviews.forEach { $0.removeFromSuperview() }
      installFallbackMaterial(configuration: configuration)
    }
  }

  private func installFallbackMaterial(
    configuration: LiquidGlassSurfaceConfiguration
  ) {
    let effect = UIBlurEffect(style: configuration.fallbackBlurStyle)
    let effectView = UIVisualEffectView(effect: effect)
    effectView.frame = containerView.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    effectView.backgroundColor = configuration.tintColor.withAlphaComponent(
      configuration.tintOpacity
    )
    containerView.addSubview(effectView)
  }

  @available(iOS 26.0, *)
  private func updateLiquidGlass(
    configuration: LiquidGlassSurfaceConfiguration
  ) {
    if let hostingController = hostingController as? UIHostingController<LiquidGlassSwiftUISurface> {
      hostingController.rootView = LiquidGlassSwiftUISurface(configuration: configuration)
      return
    }

    let hostingController = UIHostingController(
      rootView: LiquidGlassSwiftUISurface(configuration: configuration)
    )

    hostingController.view.frame = containerView.bounds
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingController.view.backgroundColor = .clear
    containerView.addSubview(hostingController.view)
    self.hostingController = hostingController
  }
}
