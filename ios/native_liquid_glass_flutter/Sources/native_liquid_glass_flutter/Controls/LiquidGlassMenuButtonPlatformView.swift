import Flutter
import UIKit

struct LiquidGlassMenuButtonConfiguration {
  let title: String
  let selectedTitle: String
  let tracksSelection: Bool
  let showsTitle: Bool
  let symbol: String?

  init(arguments: [String: Any]) {
    self.title = arguments["title"] as? String ?? ""
    self.tracksSelection = Self.bool(from: arguments["tracksSelection"]) ?? true
    self.showsTitle = Self.bool(from: arguments["showsTitle"]) ?? true
    self.symbol = arguments["symbol"] as? String

    if tracksSelection {
      self.selectedTitle = Self.titleForSelectedAction(in: arguments)
    } else {
      self.selectedTitle = ""
    }
  }

  var displayTitle: String {
    guard showsTitle else {
      return ""
    }

    return selectedTitle.isEmpty ? title : "\(title): \(selectedTitle)"
  }

  static func actionMaps(from value: Any?) -> [[String: Any]] {
    return value as? [[String: Any]] ?? []
  }

  static func bool(from value: Any?) -> Bool? {
    if let bool = value as? Bool {
      return bool
    }
    if let number = value as? NSNumber {
      return number.boolValue
    }
    return nil
  }

  private static func titleForSelectedAction(in map: [String: Any]) -> String {
    let selectedValue = map["value"] as? String
    let actions = actionMaps(from: map["actions"])
    for actionMap in actions {
      if actionMap["value"] as? String == selectedValue {
        return actionMap["title"] as? String ?? ""
      }
    }
    return ""
  }
}

struct LiquidGlassMenuActionConfiguration {
  let title: String
  let value: String
  let role: String?
  let symbol: String?
  let enabled: Bool
  let group: String?

  init(arguments: [String: Any]) {
    self.title = arguments["title"] as? String ?? ""
    self.value = arguments["value"] as? String ?? title
    self.role = arguments["role"] as? String
    self.symbol = arguments["symbol"] as? String
    self.enabled = LiquidGlassMenuButtonConfiguration.bool(
      from: arguments["enabled"]
    ) ?? true
    self.group = arguments["group"] as? String
  }
}

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

    let menuConfiguration = LiquidGlassMenuButtonConfiguration(arguments: map)
    let tintColor = LiquidGlassSurfaceConfiguration.color(
      from: map["tintColor"] as? NSNumber
    )
    let isDark = LiquidGlassMenuButtonConfiguration.bool(from: map["isDark"]) ?? false
    let isRtl = LiquidGlassMenuButtonConfiguration.bool(from: map["isRtl"]) ?? false

    containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    containerView.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    button.isEnabled =
      LiquidGlassMenuButtonConfiguration.bool(from: map["enabled"]) ?? true
    button.tintColor = tintColor
    button.accessibilityLabel = menuConfiguration.title
    button.overrideUserInterfaceStyle = isDark ? .dark : .light
    button.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    applyButtonStyle(configuration: menuConfiguration, tintColor: tintColor)
    installMenu(map: map, configuration: menuConfiguration)
  }

  private func applyButtonStyle(
    configuration menuConfiguration: LiquidGlassMenuButtonConfiguration,
    tintColor: UIColor
  ) {
    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.tinted()
      let displayTitle = menuConfiguration.displayTitle
      configuration.title = displayTitle.isEmpty ? nil : displayTitle
      if let symbol = menuConfiguration.symbol, !symbol.isEmpty {
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePlacement = .leading
        configuration.imagePadding = displayTitle.isEmpty ? 0 : 8
      } else {
        configuration.image = UIImage(systemName: "chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
      }
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
      let displayTitle = menuConfiguration.displayTitle
      button.setTitle(displayTitle.isEmpty ? nil : displayTitle, for: .normal)
      if let symbol = menuConfiguration.symbol, !symbol.isEmpty {
        button.setImage(UIImage(systemName: symbol), for: .normal)
      } else {
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
      }
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

  private func installMenu(
    map: [String: Any],
    configuration: LiquidGlassMenuButtonConfiguration
  ) {
    guard #available(iOS 14.0, *) else {
      return
    }

    let title = map["title"] as? String ?? ""
    let selectedValue = map["value"] as? String
    let actions = LiquidGlassMenuButtonConfiguration.actionMaps(
      from: map["actions"]
    ).map(LiquidGlassMenuActionConfiguration.init(arguments:))
    let children = menuChildren(
      actions: actions,
      selectedValue: selectedValue,
      tracksSelection: configuration.tracksSelection
    )

    button.menu = UIMenu(title: title, children: children)
    button.showsMenuAsPrimaryAction = true
    if #available(iOS 15.0, *) {
      button.changesSelectionAsPrimaryAction = configuration.tracksSelection
    }
  }

  @objc private func fallbackTap() {
    if #available(iOS 14.0, *) {
      return
    }

    let actions = LiquidGlassMenuButtonConfiguration.actionMaps(
      from: currentConfiguration["actions"]
    )
    guard let firstAction = actions.first,
      let value = firstAction["value"] as? String
    else {
      return
    }

    select(value: value)
  }

  private func select(value: String) {
    let tracksSelection =
      LiquidGlassMenuButtonConfiguration.bool(
        from: currentConfiguration["tracksSelection"]
      ) ?? true
    if tracksSelection {
      currentConfiguration["value"] = value
      configure(arguments: currentConfiguration)
    }
    channel.invokeMethod("onChanged", arguments: value)
  }

  @available(iOS 14.0, *)
  private func menuChildren(
    actions: [LiquidGlassMenuActionConfiguration],
    selectedValue: String?,
    tracksSelection: Bool
  ) -> [UIMenuElement] {
    var children: [UIMenuElement] = []
    var groupedActions: [LiquidGlassMenuActionConfiguration] = []
    var currentGroup: String?

    func flushGroup() {
      guard !groupedActions.isEmpty else {
        return
      }

      if let currentGroup, !currentGroup.isEmpty {
        let groupChildren = groupedActions.map { action in
          menuAction(
            action,
            selectedValue: selectedValue,
            tracksSelection: tracksSelection
          )
        }
        children.append(
          UIMenu(title: currentGroup, options: .displayInline, children: groupChildren)
        )
      } else {
        children.append(
          contentsOf: groupedActions.map { action in
            menuAction(
              action,
              selectedValue: selectedValue,
              tracksSelection: tracksSelection
            )
          }
        )
      }

      groupedActions.removeAll(keepingCapacity: true)
    }

    for action in actions {
      if action.group != currentGroup {
        flushGroup()
        currentGroup = action.group
      }
      groupedActions.append(action)
    }
    flushGroup()

    return children
  }

  @available(iOS 14.0, *)
  private func menuAction(
    _ action: LiquidGlassMenuActionConfiguration,
    selectedValue: String?,
    tracksSelection: Bool
  ) -> UIAction {
    var attributes: UIMenuElement.Attributes = []
    if action.role == "destructive" {
      attributes.insert(.destructive)
    }
    if !action.enabled {
      attributes.insert(.disabled)
    }

    return UIAction(
      title: action.title,
      image: Self.image(systemName: action.symbol),
      identifier: UIAction.Identifier(action.value),
      discoverabilityTitle: nil,
      attributes: attributes,
      state: tracksSelection && action.value == selectedValue ? .on : .off
    ) { [weak self] _ in
      self?.select(value: action.value)
    }
  }

  private static func image(systemName: String?) -> UIImage? {
    guard let systemName, !systemName.isEmpty else {
      return nil
    }
    return UIImage(systemName: systemName)
  }
}
