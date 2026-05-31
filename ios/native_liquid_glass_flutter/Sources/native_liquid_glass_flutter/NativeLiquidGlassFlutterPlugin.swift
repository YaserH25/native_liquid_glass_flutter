import Flutter
import UIKit

public class NativeLiquidGlassFlutterPlugin: NSObject, FlutterPlugin {
  private let presenter = LiquidGlassPresenter()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_liquid_glass_flutter", binaryMessenger: registrar.messenger())
    let instance = NativeLiquidGlassFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(
      LiquidGlassSurfaceFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.surface
    )
    registrar.register(
      LiquidGlassSliderFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.slider
    )
    registrar.register(
      LiquidGlassSwitchFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.switchControl
    )
    registrar.register(
      LiquidGlassSegmentedControlFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.segmentedControl
    )
    registrar.register(
      LiquidGlassStepperFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.stepper
    )
    registrar.register(
      LiquidGlassTabBarFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.tabBar
    )
    registrar.register(
      LiquidGlassNavigationBarFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.navigationBar
    )
    registrar.register(
      LiquidGlassMenuButtonFactory(messenger: registrar.messenger()),
      withId: LiquidGlassViewTypes.menuButton
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "showAlert":
      presenter.showAlert(call: call, result: result)
    case "showActionSheet":
      presenter.showActionSheet(call: call, result: result)
    case "showTimePicker":
      presenter.showTimePicker(call: call, result: result)
    case "showDatePicker":
      presenter.showDatePicker(call: call, result: result)
    case "showOptionPicker":
      presenter.showOptionPicker(call: call, result: result)
    case "showShareSheet":
      presenter.showShareSheet(call: call, result: result)
    case "cancelPresentedOverlay":
      presenter.cancelPresentedOverlay(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
