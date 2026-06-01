import UIKit

struct LiquidGlassEnvironmentConfiguration {
  let isDark: Bool
  let isRtl: Bool
  let locale: String?

  init(arguments: [String: Any]) {
    self.isDark = Self.bool(from: arguments["isDark"]) ?? false
    self.isRtl = Self.bool(from: arguments["isRtl"]) ?? false
    if let locale = arguments["locale"] as? String, !locale.isEmpty {
      self.locale = locale
    } else {
      self.locale = nil
    }
  }

  var semanticContentAttribute: UISemanticContentAttribute {
    return isRtl ? .forceRightToLeft : .forceLeftToRight
  }

  var userInterfaceStyle: UIUserInterfaceStyle {
    return isDark ? .dark : .light
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
}

extension UIView {
  func applyLiquidGlassEnvironment(
    _ environment: LiquidGlassEnvironmentConfiguration
  ) {
    overrideUserInterfaceStyle = environment.userInterfaceStyle
    semanticContentAttribute = environment.semanticContentAttribute
    accessibilityLanguage = environment.locale
  }
}
