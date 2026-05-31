import Flutter
import UIKit

struct LiquidGlassTabBarItemConfiguration {
  let index: Int
  let title: String?
  let symbol: String
  let selectedSymbol: String
  let badge: String?
  let enabled: Bool

  init(index: Int, arguments: [String: Any]) {
    let symbol = arguments["symbol"] as? String ?? "circle"

    self.index = index
    self.title = arguments["label"] as? String
    self.symbol = symbol
    self.selectedSymbol = arguments["selectedSymbol"] as? String ?? symbol
    self.badge = arguments["badge"] as? String
    self.enabled = Self.bool(from: arguments["enabled"]) ?? true
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

final class LiquidGlassTabBarPlatformView:
  NSObject, FlutterPlatformView, UITabBarDelegate
{
  private let containerView: UIView
  private let tabBar: UITabBar
  private let channel: FlutterMethodChannel
  private var tabItems: [UITabBarItem] = []

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = UIView(frame: frame)
    self.tabBar = UITabBar(frame: .zero)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/tab_bar/\(viewId)",
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
    case "setSelectedIndex":
      let map = call.arguments as? [String: Any]
      setSelectedIndex(Self.int(from: map?["index"]) ?? 0)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]
    let selectedIndex = Self.int(from: map["selectedIndex"]) ?? 0
    let selectedColor = LiquidGlassSurfaceConfiguration.color(
      from: map["selectedColor"] as? NSNumber
    )
    let backgroundColor = LiquidGlassSurfaceConfiguration.color(
      from: map["backgroundColor"] as? NSNumber
    )
    let isRtl = Self.bool(from: map["isRtl"]) ?? false
    let isDark = Self.bool(from: map["isDark"]) ?? false

    containerView.backgroundColor = .clear
    containerView.isOpaque = false
    containerView.clipsToBounds = false
    containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    containerView.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.delegate = self
    tabBar.itemPositioning = .automatic
    tabBar.isTranslucent = true
    tabBar.clipsToBounds = false
    tabBar.tintColor = selectedColor
    tabBar.overrideUserInterfaceStyle = isDark ? .dark : .light
    tabBar.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    if #unavailable(iOS 26.0) {
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.backgroundColor = backgroundColor.withAlphaComponent(
        isDark ? 0.86 : 0.78
      )
      tabBar.standardAppearance = appearance
      if #available(iOS 15.0, *) {
        tabBar.scrollEdgeAppearance = appearance
      }
    }

    tabItems = parseItems(map["items"])
    tabBar.setItems(tabItems, animated: false)
    setSelectedIndex(selectedIndex)

    if tabBar.superview == nil {
      containerView.addSubview(tabBar)
      NSLayoutConstraint.activate([
        tabBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        tabBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        tabBar.topAnchor.constraint(equalTo: containerView.topAnchor),
        tabBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
      ])
    }
  }

  private func parseItems(_ rawItems: Any?) -> [UITabBarItem] {
    let itemMaps = rawItems as? [[String: Any]] ?? []
    return itemMaps.enumerated().map { index, map in
      let configuration = LiquidGlassTabBarItemConfiguration(
        index: index,
        arguments: map
      )
      let image = UIImage(systemName: configuration.symbol)?
        .withRenderingMode(.alwaysTemplate)
      let selectedImage = UIImage(systemName: configuration.selectedSymbol)?
        .withRenderingMode(.alwaysTemplate)
      let item = UITabBarItem(
        title: configuration.title,
        image: image,
        selectedImage: selectedImage
      )
      item.tag = configuration.index
      item.accessibilityLabel = configuration.title
      item.badgeValue = configuration.badge
      item.isEnabled = configuration.enabled
      return item
    }
  }

  private func setSelectedIndex(_ index: Int) {
    guard tabItems.indices.contains(index) else {
      return
    }

    tabBar.selectedItem = tabItems[index]
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    channel.invokeMethod("onTap", arguments: item.tag)
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

  private static func int(from value: Any?) -> Int? {
    if let int = value as? Int {
      return int
    }
    if let int64 = value as? Int64 {
      return Int(int64)
    }
    if let number = value as? NSNumber {
      return number.intValue
    }
    return nil
  }
}
