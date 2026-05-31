import Flutter
import UIKit

struct LiquidGlassNavigationBarConfiguration {
  let title: String
  let canGoBack: Bool
  let foregroundColor: UIColor
  let backgroundColor: UIColor
  let isRtl: Bool
  let isDark: Bool
  let locale: String?

  init(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]

    self.title = map["title"] as? String ?? ""
    self.canGoBack = Self.bool(from: map["canGoBack"]) ?? false
    self.foregroundColor = LiquidGlassSurfaceConfiguration.color(
      from: map["foregroundColor"] as? NSNumber
    )
    self.backgroundColor = LiquidGlassSurfaceConfiguration.color(
      from: map["backgroundColor"] as? NSNumber
    )
    self.isRtl = Self.bool(from: map["isRtl"]) ?? false
    self.isDark = Self.bool(from: map["isDark"]) ?? false
    self.locale = map["locale"] as? String
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

final class LiquidGlassNavigationBarBackCoordinator {
  private var canGoBack = false
  private weak var expectedTopItem: UINavigationItem?
  private var programmaticUpdateDepth = 0

  func update(canGoBack: Bool, visibleTopItem: UINavigationItem?) {
    self.canGoBack = canGoBack
    self.expectedTopItem = visibleTopItem
  }

  func performProgrammaticUpdate(_ update: () -> Void) {
    programmaticUpdateDepth += 1
    defer { programmaticUpdateDepth -= 1 }
    update()
  }

  func shouldHandleBack(
    for item: UINavigationItem,
    visibleTopItem: UINavigationItem?
  ) -> Bool {
    guard programmaticUpdateDepth == 0 else {
      return false
    }
    guard canGoBack else {
      return false
    }
    guard let expectedTopItem else {
      return false
    }
    return item === visibleTopItem && item === expectedTopItem
  }
}

final class LiquidGlassNavigationBarPlatformView:
  NSObject, FlutterPlatformView, UINavigationBarDelegate
{
  private let containerView: UIView
  private let navigationBar: UINavigationBar
  private let channel: FlutterMethodChannel
  private let backCoordinator = LiquidGlassNavigationBarBackCoordinator()

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = UIView(frame: frame)
    self.navigationBar = UINavigationBar(frame: .zero)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/navigation_bar/\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

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
    navigationBar.delegate = nil
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
    let configuration = LiquidGlassNavigationBarConfiguration(
      arguments: arguments
    )

    containerView.backgroundColor = .clear
    containerView.isOpaque = false
    containerView.clipsToBounds = false
    containerView.overrideUserInterfaceStyle = configuration.isDark
      ? .dark
      : .light
    containerView.semanticContentAttribute = configuration.isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.delegate = self
    navigationBar.isTranslucent = true
    navigationBar.clipsToBounds = false
    navigationBar.prefersLargeTitles = false
    navigationBar.tintColor = configuration.foregroundColor
    navigationBar.titleTextAttributes = [
      .foregroundColor: configuration.foregroundColor
    ]
    navigationBar.overrideUserInterfaceStyle = configuration.isDark
      ? .dark
      : .light
    navigationBar.semanticContentAttribute = configuration.isRtl
      ? .forceRightToLeft
      : .forceLeftToRight
    navigationBar.standardAppearance = appearance(for: configuration)
    navigationBar.compactAppearance = navigationBar.standardAppearance
    if #available(iOS 15.0, *) {
      navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
      navigationBar.compactScrollEdgeAppearance = navigationBar.standardAppearance
    }

    let currentItem = UINavigationItem(title: configuration.title)
    backCoordinator.performProgrammaticUpdate {
      if configuration.canGoBack {
        let previousItem = UINavigationItem(title: "")
        navigationBar.setItems([previousItem, currentItem], animated: false)
      } else {
        navigationBar.setItems([currentItem], animated: false)
      }
    }
    backCoordinator.update(
      canGoBack: configuration.canGoBack,
      visibleTopItem: currentItem
    )

    if navigationBar.superview == nil {
      containerView.addSubview(navigationBar)
      NSLayoutConstraint.activate([
        navigationBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        navigationBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        navigationBar.topAnchor.constraint(equalTo: containerView.topAnchor),
        navigationBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
      ])
    }
  }

  private func appearance(
    for configuration: LiquidGlassNavigationBarConfiguration
  ) -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.titleTextAttributes = [
      .foregroundColor: configuration.foregroundColor
    ]
    appearance.buttonAppearance.normal.titleTextAttributes = [
      .foregroundColor: configuration.foregroundColor
    ]
    appearance.doneButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: configuration.foregroundColor
    ]

    if #available(iOS 26.0, *) {
      appearance.configureWithTransparentBackground()
    } else {
      appearance.configureWithDefaultBackground()
      appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
      appearance.backgroundColor = configuration.backgroundColor
        .withAlphaComponent(configuration.isDark ? 0.86 : 0.78)
    }

    return appearance
  }

  func navigationBar(
    _ navigationBar: UINavigationBar,
    shouldPop item: UINavigationItem
  ) -> Bool {
    if backCoordinator.shouldHandleBack(
      for: item,
      visibleTopItem: navigationBar.topItem
    ) {
      channel.invokeMethod("onBack", arguments: nil)
      return false
    }
    return true
  }
}
