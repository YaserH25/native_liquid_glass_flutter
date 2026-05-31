import Flutter
import SwiftUI
import UIKit

final class LiquidGlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let containerView: UIView
  private var hostingController: UIViewController?

  init(frame: CGRect, arguments: Any?) {
    let configuration = LiquidGlassSurfaceConfiguration(arguments: arguments)
    self.containerView = UIView(frame: frame)
    super.init()

    containerView.backgroundColor = .clear
    containerView.layer.cornerRadius = configuration.cornerRadius
    containerView.layer.cornerCurve = .continuous
    containerView.clipsToBounds = true

    if #available(iOS 26.0, *) {
      installLiquidGlass(configuration: configuration)
    } else {
      installFallbackMaterial(configuration: configuration)
    }
  }

  func view() -> UIView {
    return containerView
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
  private func installLiquidGlass(
    configuration: LiquidGlassSurfaceConfiguration
  ) {
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
