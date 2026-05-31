import UIKit

struct LiquidGlassActionModel {
  let title: String
  let value: String?
  let role: String

  init(title: String, value: String?, role: String) {
    self.title = title
    self.value = value
    self.role = role
  }

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

  var isCancel: Bool {
    return role == "cancel"
  }

  var isPreferred: Bool {
    return role == "preferred"
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

struct LiquidGlassAlertActionList {
  let actions: [LiquidGlassActionModel]

  init(arguments: [String: Any], preferredStyle: UIAlertController.Style) {
    let parsedActions = (arguments["actions"] as? [[String: Any]] ?? [])
      .compactMap(LiquidGlassActionModel.init)
    let nonCancelActions = parsedActions.filter { !$0.isCancel }
    let cancelAction = parsedActions.first { $0.isCancel }

    switch preferredStyle {
    case .actionSheet:
      var normalizedActions = nonCancelActions
      if let cancelAction {
        normalizedActions.append(cancelAction)
      } else if let cancelTitle = arguments["cancelTitle"] as? String {
        normalizedActions.append(
          LiquidGlassActionModel(
            title: cancelTitle,
            value: nil,
            role: "cancel"
          )
        )
      }
      self.actions = normalizedActions
    default:
      var normalizedActions = nonCancelActions
      if let cancelAction {
        normalizedActions.append(cancelAction)
      }
      if normalizedActions.isEmpty {
        normalizedActions.append(
          LiquidGlassActionModel(title: "OK", value: nil, role: "normal")
        )
      }
      self.actions = normalizedActions
    }
  }
}
