import Flutter
import UIKit

final class LiquidGlassMenuButtonPlatformView: NSObject, FlutterPlatformView {
  private let containerView: UIView
  private let button: UIButton
  private let channel: FlutterMethodChannel
  private var currentConfiguration: [String: Any] = [:]

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = UIView(frame: frame)
    self.button = UIButton(type: .system)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/menu_button/\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    installButton()
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
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func installButton() {
    containerView.backgroundColor = .clear
    containerView.isOpaque = false

    button.translatesAutoresizingMaskIntoConstraints = false
    button.contentHorizontalAlignment = .fill
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.addTarget(self, action: #selector(fallbackTap), for: .touchUpInside)

    containerView.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      button.topAnchor.constraint(equalTo: containerView.topAnchor),
      button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
  }

  private func configure(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]
    currentConfiguration = map

    let selectedTitle = titleForSelectedAction(in: map)
    let tintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["tintColor"] as? NSNumber
    )
    let isDark = Self.bool(from: map["isDark"]) ?? false
    let isRtl = Self.bool(from: map["isRtl"]) ?? false

    containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    containerView.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    button.isEnabled = Self.bool(from: map["enabled"]) ?? true
    button.tintColor = tintColor
    button.overrideUserInterfaceStyle = isDark ? .dark : .light
    button.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    applyButtonStyle(map: map, selectedTitle: selectedTitle, tintColor: tintColor)
    installMenu(map: map)
  }

  private func applyButtonStyle(
    map: [String: Any],
    selectedTitle: String,
    tintColor: UIColor
  ) {
    let title = map["title"] as? String ?? ""
    let displayTitle = selectedTitle.isEmpty ? title : "\(title): \(selectedTitle)"

    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.tinted()
      configuration.title = displayTitle
      configuration.image = UIImage(systemName: "chevron.down")
      configuration.imagePlacement = .trailing
      configuration.imagePadding = 8
      configuration.baseForegroundColor = tintColor
      configuration.baseBackgroundColor = tintColor.withAlphaComponent(0.14)
      configuration.cornerStyle = .capsule
      configuration.contentInsets = NSDirectionalEdgeInsets(
        top: 10,
        leading: 16,
        bottom: 10,
        trailing: 16
      )
      button.configuration = configuration
    } else {
      button.setTitle(displayTitle, for: .normal)
      button.setTitleColor(tintColor, for: .normal)
      button.backgroundColor = tintColor.withAlphaComponent(0.14)
      button.layer.cornerRadius = 20
      button.contentEdgeInsets = UIEdgeInsets(
        top: 10,
        left: 16,
        bottom: 10,
        right: 16
      )
    }
  }

  private func installMenu(map: [String: Any]) {
    guard #available(iOS 14.0, *) else {
      return
    }

    let title = map["title"] as? String ?? ""
    let selectedValue = map["value"] as? String
    let actions = Self.actionMaps(from: map["actions"])
    let children = actions.map { actionMap in
      let actionTitle = actionMap["title"] as? String ?? ""
      let actionValue = actionMap["value"] as? String ?? actionTitle
      let role = actionMap["role"] as? String
      var attributes: UIMenuElement.Attributes = []
      if role == "destructive" {
        attributes.insert(.destructive)
      }

      return UIAction(
        title: actionTitle,
        image: nil,
        identifier: UIAction.Identifier(actionValue),
        discoverabilityTitle: nil,
        attributes: attributes,
        state: actionValue == selectedValue ? .on : .off
      ) { [weak self] _ in
        self?.select(value: actionValue)
      }
    }

    button.menu = UIMenu(title: title, children: children)
    button.showsMenuAsPrimaryAction = true
  }

  @objc private func fallbackTap() {
    if #available(iOS 14.0, *) {
      return
    }

    let actions = Self.actionMaps(from: currentConfiguration["actions"])
    guard let firstAction = actions.first,
      let value = firstAction["value"] as? String
    else {
      return
    }

    select(value: value)
  }

  private func select(value: String) {
    currentConfiguration["value"] = value
    configure(arguments: currentConfiguration)
    channel.invokeMethod("onChanged", arguments: value)
  }

  private func titleForSelectedAction(in map: [String: Any]) -> String {
    let selectedValue = map["value"] as? String
    let actions = Self.actionMaps(from: map["actions"])
    for actionMap in actions {
      if actionMap["value"] as? String == selectedValue {
        return actionMap["title"] as? String ?? ""
      }
    }
    return ""
  }

  private static func actionMaps(from value: Any?) -> [[String: Any]] {
    return value as? [[String: Any]] ?? []
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
