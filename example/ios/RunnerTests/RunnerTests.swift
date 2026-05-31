import Flutter
import SwiftUI
import UIKit
import XCTest

// If your plugin has been explicitly set to "type: .dynamic" in the Package.swift,
// you will need to add your plugin as a dependency of RunnerTests within Xcode.

@testable import native_liquid_glass_flutter

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testGetPlatformVersion() {
    let plugin = NativeLiquidGlassFlutterPlugin()

    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testCancelPresentedOverlayReturnsFalseWhenNoOverlayIsPresented() {
    let plugin = NativeLiquidGlassFlutterPlugin()
    let call = FlutterMethodCall(methodName: "cancelPresentedOverlay", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as? Bool, false)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testSteppedSliderKeepsRawThumbValueWhileDragging() {
    let coordinator = LiquidGlassSliderValueCoordinator(
      minimumValue: 0,
      maximumValue: 1,
      step: 0.25
    )

    let liveValue = coordinator.value(for: 0.38, isTracking: true)

    XCTAssertEqual(liveValue.reportedValue, 0.5, accuracy: 0.0001)
    XCTAssertEqual(liveValue.displayValue, 0.38, accuracy: 0.0001)
  }

  func testSteppedSliderSnapsThumbValueWhenDragEnds() {
    let coordinator = LiquidGlassSliderValueCoordinator(
      minimumValue: 0,
      maximumValue: 1,
      step: 0.25
    )

    let finalValue = coordinator.value(for: 0.38, isTracking: false)

    XCTAssertEqual(finalValue.reportedValue, 0.5, accuracy: 0.0001)
    XCTAssertEqual(finalValue.displayValue, 0.5, accuracy: 0.0001)
  }

  func testSurfaceConfigurationParsesCompositionHints() {
    let configuration = LiquidGlassSurfaceConfiguration(arguments: [
      "cornerStyle": "top",
      "isDark": true,
      "interactive": true,
      "cornerRadius": 34,
      "role": "modal",
      "nativePolicy": "native"
    ])

    XCTAssertEqual(configuration.cornerStyle, "top")
    XCTAssertTrue(configuration.isDark)
    XCTAssertTrue(configuration.interactive)
    XCTAssertEqual(configuration.cornerRadius, 34)
    XCTAssertEqual(configuration.role, "modal")
    XCTAssertEqual(configuration.nativePolicy, "native")
  }

  func testSurfaceConfigurationHandlesMissingValues() {
    let configuration = LiquidGlassSurfaceConfiguration(arguments: [:])

    XCTAssertEqual(configuration.cornerStyle, "all")
    XCTAssertFalse(configuration.isDark)
  }

  func testSurfaceConfigurationResolvesCornerStyle() {
    let topConfiguration = LiquidGlassSurfaceConfiguration(arguments: [
      "cornerStyle": "top",
      "cornerRadius": 34
    ])
    let noneConfiguration = LiquidGlassSurfaceConfiguration(arguments: [
      "cornerStyle": "none",
      "cornerRadius": 34
    ])

    XCTAssertEqual(topConfiguration.resolvedCornerRadius, 34)
    XCTAssertEqual(
      topConfiguration.maskedCorners,
      [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    )
    XCTAssertEqual(noneConfiguration.resolvedCornerRadius, 0)
    XCTAssertEqual(noneConfiguration.maskedCorners, [])
  }

  func testNavigationBarViewTypeConstantMatchesDartBridge() {
    XCTAssertEqual(
      LiquidGlassViewTypes.navigationBar,
      "native_liquid_glass_flutter/liquid_glass_navigation_bar"
    )
  }

  func testNavigationBarConfigurationParsesBridgeArguments() {
    let configuration = LiquidGlassNavigationBarConfiguration(arguments: [
      "title": "Native",
      "canGoBack": NSNumber(value: true),
      "foregroundColor": NSNumber(value: 0xFF102030),
      "backgroundColor": NSNumber(value: 0x80405060),
      "isRtl": NSNumber(value: true),
      "isDark": NSNumber(value: true),
      "locale": "ar"
    ])

    XCTAssertEqual(configuration.title, "Native")
    XCTAssertTrue(configuration.canGoBack)
    XCTAssertTrue(configuration.isRtl)
    XCTAssertTrue(configuration.isDark)
    XCTAssertEqual(configuration.locale, "ar")
    XCTAssertEqual(
      configuration.foregroundColor,
      LiquidGlassSurfaceConfiguration.color(from: NSNumber(value: 0xFF102030))
    )
    XCTAssertEqual(
      configuration.backgroundColor,
      LiquidGlassSurfaceConfiguration.color(from: NSNumber(value: 0x80405060))
    )
  }

  func testNavigationBarConfigurationHandlesMissingValues() {
    let configuration = LiquidGlassNavigationBarConfiguration(arguments: [:])

    XCTAssertEqual(configuration.title, "")
    XCTAssertFalse(configuration.canGoBack)
    XCTAssertFalse(configuration.isRtl)
    XCTAssertFalse(configuration.isDark)
    XCTAssertNil(configuration.locale)
  }

  func testNavigationBarConfigurationUsesDirectionalBackIndicatorSymbol() {
    let ltrConfiguration = LiquidGlassNavigationBarConfiguration(arguments: [
      "isRtl": NSNumber(value: false)
    ])
    let rtlConfiguration = LiquidGlassNavigationBarConfiguration(arguments: [
      "isRtl": NSNumber(value: true)
    ])

    XCTAssertEqual(ltrConfiguration.backIndicatorSymbolName, "chevron.backward")
    XCTAssertEqual(rtlConfiguration.backIndicatorSymbolName, "chevron.forward")
  }

  func testNavigationBarBackCoordinatorOnlyHandlesEnabledVisibleTopItem() {
    let coordinator = LiquidGlassNavigationBarBackCoordinator()
    let previousItem = UINavigationItem(title: "")
    let currentItem = UINavigationItem(title: "Native")

    coordinator.update(canGoBack: true, visibleTopItem: currentItem)

    XCTAssertTrue(
      coordinator.shouldHandleBack(
        for: currentItem,
        visibleTopItem: currentItem
      )
    )
    XCTAssertFalse(
      coordinator.shouldHandleBack(
        for: previousItem,
        visibleTopItem: currentItem
      )
    )

    coordinator.update(canGoBack: false, visibleTopItem: currentItem)

    XCTAssertFalse(
      coordinator.shouldHandleBack(
        for: currentItem,
        visibleTopItem: currentItem
      )
    )
  }

  func testNavigationBarBackCoordinatorSuppressesProgrammaticUpdates() {
    let coordinator = LiquidGlassNavigationBarBackCoordinator()
    let currentItem = UINavigationItem(title: "Native")

    coordinator.update(canGoBack: true, visibleTopItem: currentItem)

    coordinator.performProgrammaticUpdate {
      XCTAssertFalse(
        coordinator.shouldHandleBack(
          for: currentItem,
          visibleTopItem: currentItem
        )
      )
    }
  }

  func testMenuButtonConfigurationTracksSelectedValue() {
    let configuration = LiquidGlassMenuButtonConfiguration(arguments: [
      "title": "Density",
      "value": "comfortable",
      "tracksSelection": NSNumber(value: true),
      "showsTitle": NSNumber(value: true),
      "actions": [
        ["title": "Compact", "value": "compact"],
        ["title": "Comfortable", "value": "comfortable"]
      ]
    ])

    XCTAssertTrue(configuration.tracksSelection)
    XCTAssertTrue(configuration.showsTitle)
    XCTAssertEqual(configuration.displayTitle, "Density: Comfortable")
  }

  func testMenuButtonConfigurationSupportsIconOnlyPullDownActions() {
    let configuration = LiquidGlassMenuButtonConfiguration(arguments: [
      "title": "Actions",
      "value": "",
      "tracksSelection": NSNumber(value: false),
      "showsTitle": NSNumber(value: false),
      "symbol": "ellipsis.circle",
      "actions": [
        ["title": "Duplicate", "value": "duplicate"],
        ["title": "Archive", "value": "archive"]
      ]
    ])

    XCTAssertFalse(configuration.tracksSelection)
    XCTAssertFalse(configuration.showsTitle)
    XCTAssertEqual(configuration.symbol, "ellipsis.circle")
    XCTAssertEqual(configuration.displayTitle, "")
  }

  func testSurfaceBackdropViewDoesNotCaptureTouches() {
    let view = LiquidGlassPassthroughView(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100)
    )

    view.isUserInteractionEnabled = true

    XCTAssertFalse(view.point(inside: CGPoint(x: 50, y: 50), with: nil))
  }

  func testActionSheetNormalizesToSingleCancelAction() {
    let actionList = LiquidGlassAlertActionList(
      arguments: [
        "cancelTitle": "Close",
        "actions": [
          ["title": "Keep", "value": "keep", "role": "normal"],
          ["title": "Cancel", "value": "cancel", "role": "cancel"]
        ]
      ],
      preferredStyle: .actionSheet
    )

    XCTAssertEqual(actionList.actions.filter(\.isCancel).count, 1)
    XCTAssertEqual(actionList.actions.map(\.title), ["Keep", "Cancel"])
  }

  func testActionSheetAddsCancelWhenMissing() {
    let actionList = LiquidGlassAlertActionList(
      arguments: [
        "cancelTitle": "Close",
        "actions": [
          ["title": "Keep", "value": "keep", "role": "normal"]
        ]
      ],
      preferredStyle: .actionSheet
    )

    XCTAssertEqual(actionList.actions.filter(\.isCancel).count, 1)
    XCTAssertEqual(actionList.actions.last?.title, "Close")
  }

  func testAlertGetsDismissActionWhenNoActionsAreProvided() {
    let actionList = LiquidGlassAlertActionList(
      arguments: ["actions": []],
      preferredStyle: .alert
    )

    XCTAssertEqual(actionList.actions.map(\.title), ["OK"])
    XCTAssertNil(actionList.actions.first?.value)
  }

  func testActiveOverlayRegistryCompletesOriginalResultWhenCancelled() {
    let registry = LiquidGlassPresentedOverlayRegistry()
    let overlay = UIViewController()
    var originalResults: [Any?] = []
    let resultGuard = LiquidGlassResultGuard(
      result: { originalResults.append($0) },
      onComplete: {}
    )

    registry.register(viewController: overlay, resultGuard: resultGuard)

    XCTAssertTrue(registry.cancel(viewController: overlay))
    XCTAssertEqual(originalResults.count, 1)
    XCTAssertNil(originalResults[0])
  }

  func testActiveOverlayRegistryIgnoresLaterDismissalAfterCancellation() {
    let registry = LiquidGlassPresentedOverlayRegistry()
    let overlay = UIViewController()
    var originalResults: [Any?] = []
    let resultGuard = LiquidGlassResultGuard(
      result: { originalResults.append($0) },
      onComplete: {}
    )

    registry.register(viewController: overlay, resultGuard: resultGuard)

    XCTAssertTrue(registry.cancel(viewController: overlay))
    resultGuard.complete(nil)

    XCTAssertEqual(originalResults.count, 1)
    XCTAssertNil(originalResults[0])
  }

  func testActiveOverlayRegistryReturnsFalseForInactiveOverlay() {
    let registry = LiquidGlassPresentedOverlayRegistry()
    let overlay = UIViewController()

    XCTAssertFalse(registry.cancel(viewController: overlay))
  }

  func testHostingContainerInstallsChildController() {
    if #available(iOS 26.0, *) {
      let parent = UIViewController()
      let container = LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>()
      let configuration = LiquidGlassSurfaceConfiguration(arguments: [
        "cornerRadius": 20,
        "isDark": true
      ])

      parent.view.addSubview(container)
      container.frame = parent.view.bounds
      container.didMoveToWindow()
      container.install(
        rootView: LiquidGlassSwiftUISurface(configuration: configuration),
        isDark: true
      )

      XCTAssertEqual(parent.children.count, 1)

      container.uninstall()

      XCTAssertTrue(parent.children.isEmpty)
    }
  }

  func testHostingContainerDefersChildControllerUntilParentIsAvailable() {
    if #available(iOS 26.0, *) {
      let parent = UIViewController()
      let container = LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>()
      let configuration = LiquidGlassSurfaceConfiguration(arguments: [
        "cornerRadius": 20
      ])

      container.install(
        rootView: LiquidGlassSwiftUISurface(configuration: configuration),
        isDark: false
      )

      XCTAssertFalse(container.subviews.isEmpty)
      XCTAssertTrue(parent.children.isEmpty)

      parent.view.addSubview(container)
      container.didMoveToWindow()

      XCTAssertEqual(parent.children.count, 1)

      container.uninstall()

      XCTAssertTrue(parent.children.isEmpty)
    }
  }

}
