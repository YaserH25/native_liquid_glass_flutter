import UIKit

struct LiquidGlassActionModel {
  let title: String
  let value: String
  let role: String

  init?(dictionary: [String: Any]) {
    guard
      let title = dictionary["title"] as? String,
      let value = dictionary["value"] as? String
    else {
      return nil
    }

    self.title = title
    self.value = value
    self.role = dictionary["role"] as? String ?? "normal"
  }

  var style: UIAlertAction.Style {
    switch role {
    case "destructive":
      return .destructive
    case "cancel":
      return .cancel
    default:
      return .default
    }
  }
}
