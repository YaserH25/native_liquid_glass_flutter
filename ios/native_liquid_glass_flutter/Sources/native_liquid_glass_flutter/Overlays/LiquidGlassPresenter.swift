import Flutter
import UIKit

final class LiquidGlassPresenter: NSObject {
  private var dismissalDelegates: [ObjectIdentifier: LiquidGlassDismissalDelegate] = [:]
  private let activeOverlays = LiquidGlassPresentedOverlayRegistry()

  static func shouldInstallDismissalDelegate(for viewController: UIViewController) -> Bool {
    if let alert = viewController as? UIAlertController,
      alert.preferredStyle == .alert
    {
      return false
    }
    return true
  }

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
    let resultGuard = makeResultGuard(for: alert, result: result)
    alert.view.addSubview(datePicker)
    datePicker.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
      datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
      datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 42),
      datePicker.heightAnchor.constraint(equalToConstant: 180)
    ])

    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
      resultGuard.complete(nil)
    })
    alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
      let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
      resultGuard.complete((components.hour ?? 0) * 60 + (components.minute ?? 0))
    })

    present(alert: alert, resultGuard: resultGuard)
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
    let resultGuard = makeResultGuard(for: alert, result: result)
    alert.view.addSubview(datePicker)
    datePicker.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
      datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
      datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 42),
      datePicker.heightAnchor.constraint(equalToConstant: 180)
    ])

    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
      resultGuard.complete(nil)
    })
    alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
      let milliseconds = Int(datePicker.date.timeIntervalSince1970 * 1000)
      resultGuard.complete(milliseconds)
    })

    present(alert: alert, resultGuard: resultGuard)
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
    let resultGuard = makeResultGuard(for: activity, result: result)
    activity.completionWithItemsHandler = { _, completed, _, _ in
      resultGuard.complete(completed)
    }

    present(viewController: activity, resultGuard: resultGuard)
  }

  func cancelPresentedOverlay(result: @escaping FlutterResult) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?.cancelPresentedOverlay(result: result)
      }
      return
    }

    guard
      let viewController = topViewController(),
      viewController is UIAlertController || viewController is UIActivityViewController,
      activeOverlays.cancel(viewController: viewController)
    else {
      result(false)
      return
    }

    viewController.dismiss(animated: true) {
      result(true)
    }
  }

  private func presentAlert(
    arguments: [String: Any],
    preferredStyle: UIAlertController.Style,
    result: @escaping FlutterResult
  ) {
    let title = arguments["title"] as? String
    let message = arguments["message"] as? String
    let actionList = LiquidGlassAlertActionList(
      arguments: arguments,
      preferredStyle: preferredStyle
    )
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: preferredStyle
    )
    let resultGuard = makeResultGuard(for: alert, result: result)
    var preferredAction: UIAlertAction?

    for action in actionList.actions {
      let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
        resultGuard.complete(action.value)
      }
      alert.addAction(alertAction)
      if action.isPreferred {
        preferredAction = alertAction
      }
    }

    if preferredStyle == .alert {
      alert.preferredAction = preferredAction
    }
    present(alert: alert, resultGuard: resultGuard)
  }

  private func present(alert: UIAlertController, resultGuard: LiquidGlassResultGuard) {
    present(viewController: alert, resultGuard: resultGuard)
  }

  private func present(viewController presented: UIViewController, resultGuard: LiquidGlassResultGuard) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?.present(viewController: presented, resultGuard: resultGuard)
      }
      return
    }

    guard let viewController = topViewController() else {
      resultGuard.complete(FlutterError(code: "no_view_controller", message: nil, details: nil))
      return
    }

    guard
      !viewController.isBeingDismissed,
      !viewController.isBeingPresented,
      !(viewController is UIAlertController),
      !(viewController is UIActivityViewController)
    else {
      resultGuard.complete(
        FlutterError(
          code: "presentation_busy",
          message: "Another native overlay is already being presented.",
          details: nil
        )
      )
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

    let identifier = ObjectIdentifier(presented)
    activeOverlays.register(viewController: presented, resultGuard: resultGuard)
    if Self.shouldInstallDismissalDelegate(for: presented) {
      let delegate = LiquidGlassDismissalDelegate(resultGuard: resultGuard)
      dismissalDelegates[identifier] = delegate
      presented.presentationController?.delegate = delegate
    }
    viewController.present(presented, animated: true)
  }

  private func makeResultGuard(
    for viewController: UIViewController,
    result: @escaping FlutterResult
  ) -> LiquidGlassResultGuard {
    let identifier = ObjectIdentifier(viewController)
    return LiquidGlassResultGuard(result: result) { [weak self] in
      self?.dismissalDelegates.removeValue(forKey: identifier)
      self?.activeOverlays.unregister(identifier: identifier)
    }
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

final class LiquidGlassPresentedOverlayRegistry {
  private var resultGuards: [ObjectIdentifier: LiquidGlassResultGuard] = [:]

  func register(viewController: UIViewController, resultGuard: LiquidGlassResultGuard) {
    resultGuards[ObjectIdentifier(viewController)] = resultGuard
  }

  func unregister(viewController: UIViewController) {
    unregister(identifier: ObjectIdentifier(viewController))
  }

  func unregister(identifier: ObjectIdentifier) {
    resultGuards.removeValue(forKey: identifier)
  }

  func cancel(viewController: UIViewController) -> Bool {
    let identifier = ObjectIdentifier(viewController)
    guard let resultGuard = resultGuards.removeValue(forKey: identifier) else {
      return false
    }

    resultGuard.complete(nil)
    return true
  }
}

final class LiquidGlassResultGuard {
  private let result: FlutterResult
  private let onComplete: () -> Void
  private var completed = false

  init(result: @escaping FlutterResult, onComplete: @escaping () -> Void) {
    self.result = result
    self.onComplete = onComplete
  }

  func complete(_ value: Any?) {
    guard !completed else {
      return
    }

    completed = true
    result(value)
    onComplete()
  }
}

final class LiquidGlassDismissalDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
  private let resultGuard: LiquidGlassResultGuard

  init(resultGuard: LiquidGlassResultGuard) {
    self.resultGuard = resultGuard
    super.init()
  }

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    resultGuard.complete(nil)
  }
}
