import Flutter
import UIKit

final class LiquidGlassPresenter {
  func showAlert(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_arguments", message: nil, details: nil))
      return
    }

    presentAlert(
      arguments: arguments,
      preferredStyle: .alert,
      result: result
    )
  }

  func showActionSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_arguments", message: nil, details: nil))
      return
    }

    presentAlert(
      arguments: arguments,
      preferredStyle: .actionSheet,
      result: result
    )
  }

  func showOptionPicker(call: FlutterMethodCall, result: @escaping FlutterResult) {
    showActionSheet(call: call, result: result)
  }

  func showTimePicker(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_arguments", message: nil, details: nil))
      return
    }

    let initialMinutes = arguments["initialMinutes"] as? Int ?? 0
    let minuteInterval = arguments["minuteInterval"] as? Int ?? 1
    let title = arguments["title"] as? String
    let confirmTitle = arguments["confirmTitle"] as? String ?? "Done"
    let cancelTitle = arguments["cancelTitle"] as? String ?? "Cancel"
    let datePicker = UIDatePicker()
    let calendar = Calendar.current
    let date = calendar.date(
      bySettingHour: initialMinutes / 60,
      minute: initialMinutes % 60,
      second: 0,
      of: Date()
    ) ?? Date()

    datePicker.datePickerMode = .time
    datePicker.minuteInterval = max(1, min(30, minuteInterval))
    datePicker.date = date

    if #available(iOS 13.4, *) {
      datePicker.preferredDatePickerStyle = .wheels
    }

    let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
    alert.view.addSubview(datePicker)
    datePicker.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
      datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
      datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 42),
      datePicker.heightAnchor.constraint(equalToConstant: 180)
    ])

    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
      result(nil)
    })
    alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
      let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
      result((components.hour ?? 0) * 60 + (components.minute ?? 0))
    })

    present(alert: alert, result: result)
  }

  func showDatePicker(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_arguments", message: nil, details: nil))
      return
    }

    let initialMilliseconds = arguments["initialDate"] as? Int ?? 0
    let minimumMilliseconds = arguments["minimumDate"] as? Int
    let maximumMilliseconds = arguments["maximumDate"] as? Int
    let title = arguments["title"] as? String
    let confirmTitle = arguments["confirmTitle"] as? String ?? "Done"
    let cancelTitle = arguments["cancelTitle"] as? String ?? "Cancel"
    let datePicker = UIDatePicker()

    datePicker.datePickerMode = .date
    datePicker.date = Date(timeIntervalSince1970: Double(initialMilliseconds) / 1000.0)

    if let minimumMilliseconds = minimumMilliseconds {
      datePicker.minimumDate = Date(timeIntervalSince1970: Double(minimumMilliseconds) / 1000.0)
    }

    if let maximumMilliseconds = maximumMilliseconds {
      datePicker.maximumDate = Date(timeIntervalSince1970: Double(maximumMilliseconds) / 1000.0)
    }

    if #available(iOS 13.4, *) {
      datePicker.preferredDatePickerStyle = .wheels
    }

    let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
    alert.view.addSubview(datePicker)
    datePicker.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
      datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
      datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 42),
      datePicker.heightAnchor.constraint(equalToConstant: 180)
    ])

    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
      result(nil)
    })
    alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
      let milliseconds = Int(datePicker.date.timeIntervalSince1970 * 1000)
      result(milliseconds)
    })

    present(alert: alert, result: result)
  }

  func showShareSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let items = arguments["items"] as? [String]
    else {
      result(FlutterError(code: "bad_arguments", message: nil, details: nil))
      return
    }

    let activity = UIActivityViewController(
      activityItems: items,
      applicationActivities: nil
    )
    activity.completionWithItemsHandler = { _, completed, _, _ in
      result(completed)
    }

    present(viewController: activity, result: result)
  }

  private func presentAlert(
    arguments: [String: Any],
    preferredStyle: UIAlertController.Style,
    result: @escaping FlutterResult
  ) {
    let title = arguments["title"] as? String
    let message = arguments["message"] as? String
    let cancelTitle = arguments["cancelTitle"] as? String
    let actions = (arguments["actions"] as? [[String: Any]] ?? [])
      .compactMap(LiquidGlassActionModel.init)
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: preferredStyle
    )

    for action in actions {
      alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
        result(action.value)
      })
    }

    if preferredStyle == .actionSheet, let cancelTitle = cancelTitle {
      alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
        result(nil)
      })
    }

    present(alert: alert, result: result)
  }

  private func present(alert: UIAlertController, result: @escaping FlutterResult) {
    present(viewController: alert, result: result)
  }

  private func present(viewController presented: UIViewController, result: @escaping FlutterResult) {
    guard let viewController = topViewController() else {
      result(FlutterError(code: "no_view_controller", message: nil, details: nil))
      return
    }

    if let popover = presented.popoverPresentationController {
      popover.sourceView = viewController.view
      popover.sourceRect = CGRect(
        x: viewController.view.bounds.midX,
        y: viewController.view.bounds.maxY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }

    viewController.present(presented, animated: true)
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
    let window = scenes
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    var controller = window?.rootViewController

    while let presented = controller?.presentedViewController {
      controller = presented
    }

    return controller
  }
}
