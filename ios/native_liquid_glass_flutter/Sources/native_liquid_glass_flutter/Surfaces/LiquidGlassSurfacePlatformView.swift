import Flutter
import SwiftUI
import UIKit

final class LiquidGlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let containerView: LiquidGlassPassthroughView
  private let channel: FlutterMethodChannel
  private var hostingContainer: UIView?

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = LiquidGlassPassthroughView(frame: frame)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/surface_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    containerView.isOpaque = false
    containerView.backgroundColor = .clear
    configure(arguments: arguments)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
  }

  deinit {
    uninstallHostingContainerIfNeeded()
    channel.setMethodCallHandler(nil)
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

    containerView.isOpaque = false
    containerView.backgroundColor = .clear
    containerView.applyLiquidGlassEnvironment(configuration.environment)
    containerView.isUserInteractionEnabled = false
    containerView.layer.cornerRadius = configuration.resolvedCornerRadius
    containerView.layer.cornerCurve = .continuous
    containerView.layer.maskedCorners = configuration.maskedCorners
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
    uninstallHostingContainerIfNeeded()

    let effect = UIBlurEffect(style: configuration.fallbackBlurStyle)
    let effectView = UIVisualEffectView(effect: effect)
    effectView.frame = containerView.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    effectView.isOpaque = false
    effectView.isUserInteractionEnabled = false
    effectView.applyLiquidGlassEnvironment(configuration.environment)
    effectView.backgroundColor = configuration.tintColor.withAlphaComponent(
      configuration.tintOpacity
    )
    containerView.addSubview(effectView)
  }

  @available(iOS 26.0, *)
  private func updateLiquidGlass(
    configuration: LiquidGlassSurfaceConfiguration
  ) {
    let hostingContainer = resolveHostingContainer()
    containerView.subviews
      .filter { $0 !== hostingContainer }
      .forEach { $0.removeFromSuperview() }

    hostingContainer.install(
      rootView: LiquidGlassSwiftUISurface(configuration: configuration),
      environment: configuration.environment
    )
  }

  @available(iOS 26.0, *)
  private func resolveHostingContainer()
    -> LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>
  {
    if let hostingContainer = hostingContainer
      as? LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>
    {
      hostingContainer.frame = containerView.bounds
      return hostingContainer
    }

    let hostingContainer = LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>(
      frame: containerView.bounds
    )
    hostingContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(hostingContainer)
    self.hostingContainer = hostingContainer
    return hostingContainer
  }

  private func uninstallHostingContainerIfNeeded() {
    if #available(iOS 26.0, *) {
      (hostingContainer as? LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>)?
        .uninstall()
    }

    hostingContainer?.removeFromSuperview()
    hostingContainer = nil
  }
}
