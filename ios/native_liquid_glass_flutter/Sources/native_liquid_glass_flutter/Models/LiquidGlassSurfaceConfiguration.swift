import UIKit

struct LiquidGlassSurfaceConfiguration {
  let tintColor: UIColor
  let tintOpacity: CGFloat
  let cornerRadius: CGFloat
  let interactive: Bool
  let intensity: String
  let cornerStyle: String
  let isDark: Bool
  let environment: LiquidGlassEnvironmentConfiguration
  let role: String
  let nativePolicy: String

  init(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]
    let colorNumber = map["tintColor"] as? NSNumber
    let opacityNumber = map["tintOpacity"] as? NSNumber
    let radiusNumber = map["cornerRadius"] as? NSNumber

    self.tintColor = LiquidGlassSurfaceConfiguration.color(from: colorNumber)
    self.tintOpacity = CGFloat(opacityNumber?.doubleValue ?? 0.16)
    self.cornerRadius = CGFloat(radiusNumber?.doubleValue ?? 28)
    self.interactive = map["interactive"] as? Bool ?? false
    self.intensity = map["intensity"] as? String ?? "regular"
    self.cornerStyle = map["cornerStyle"] as? String ?? "all"
    let environment = LiquidGlassEnvironmentConfiguration(arguments: map)
    self.environment = environment
    self.isDark = environment.isDark
    self.role = map["role"] as? String ?? "content"
    self.nativePolicy = map["nativePolicy"] as? String ?? "automatic"
  }

  var resolvedCornerRadius: CGFloat {
    return cornerStyle == "none" ? 0 : cornerRadius
  }

  var maskedCorners: CACornerMask {
    switch cornerStyle {
    case "top":
      return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    case "none":
      return []
    default:
      return [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner
      ]
    }
  }

  var fallbackBlurStyle: UIBlurEffect.Style {
    switch intensity {
    case "subtle":
      return .systemThinMaterial
    case "prominent":
      return .systemMaterial
    default:
      return .systemUltraThinMaterial
    }
  }

  static func color(from number: NSNumber?) -> UIColor {
    guard let unsigned = number?.uint32Value else {
      return UIColor.systemBackground
    }

    let alpha = CGFloat((unsigned >> 24) & 0xFF) / 255.0
    let red = CGFloat((unsigned >> 16) & 0xFF) / 255.0
    let green = CGFloat((unsigned >> 8) & 0xFF) / 255.0
    let blue = CGFloat(unsigned & 0xFF) / 255.0

    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
