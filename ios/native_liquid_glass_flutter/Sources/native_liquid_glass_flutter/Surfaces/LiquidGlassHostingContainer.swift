import SwiftUI
import UIKit

@available(iOS 26.0, *)
final class LiquidGlassHostingContainer<Content: View>: UIView {
  private var hostingController: UIHostingController<Content>?
  private var hostedViewConstraints: [NSLayoutConstraint] = []
  private weak var parentViewController: UIViewController?

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureContainer()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureContainer()
  }

  deinit {
    uninstall()
  }

  func install(
    rootView: Content,
    environment: LiquidGlassEnvironmentConfiguration
  ) {
    if let hostingController {
      hostingController.rootView = rootView
      configureHostedView(hostingController.view, environment: environment)
    } else {
      let hostingController = UIHostingController(rootView: rootView)
      configureHostedView(hostingController.view, environment: environment)
      self.hostingController = hostingController
    }

    updateContainmentIfNeeded()
  }

  func uninstall() {
    detachFromParent()
    removeHostedView()
    hostingController = nil
  }

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    updateContainmentIfNeeded()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateContainmentIfNeeded()
  }

  private func configureContainer() {
    isOpaque = false
    isUserInteractionEnabled = false
    backgroundColor = .clear
  }

  private func updateContainmentIfNeeded() {
    guard let hostingController else {
      return
    }

    let nextParent = nearestParentViewController()
    if nextParent === parentViewController {
      installHostedView()
      return
    }

    detachFromParent()

    guard let nextParent else {
      installHostedView()
      return
    }

    nextParent.addChild(hostingController)
    installHostedView(forceReinstall: true)
    hostingController.didMove(toParent: nextParent)
    parentViewController = nextParent
  }

  private func installHostedView(forceReinstall: Bool = false) {
    guard let hostedView = hostingController?.view else {
      return
    }

    if hostedView.superview === self && !forceReinstall {
      return
    }

    removeHostedView()
    addSubview(hostedView)

    hostedViewConstraints = [
      hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostedView.topAnchor.constraint(equalTo: topAnchor),
      hostedView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
    NSLayoutConstraint.activate(hostedViewConstraints)
  }

  private func removeHostedView() {
    NSLayoutConstraint.deactivate(hostedViewConstraints)
    hostedViewConstraints = []
    hostingController?.view.removeFromSuperview()
  }

  private func detachFromParent() {
    guard let hostingController,
      hostingController.parent != nil
    else {
      parentViewController = nil
      return
    }

    hostingController.willMove(toParent: nil)
    removeHostedView()
    hostingController.removeFromParent()
    parentViewController = nil
  }

  private func configureHostedView(
    _ view: UIView,
    environment: LiquidGlassEnvironmentConfiguration
  ) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isOpaque = false
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.applyLiquidGlassEnvironment(environment)
  }

  private func nearestParentViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let current = responder {
      if let viewController = current as? UIViewController {
        return viewController
      }
      responder = current.next
    }
    return nil
  }
}
