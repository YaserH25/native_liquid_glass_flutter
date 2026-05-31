# Native Bridge Architecture Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden the Flutter-to-iOS Liquid Glass bridge so native platform views, navigation chrome, overlays, and tests are safe for long-term mobile app use.

**Architecture:** Keep the package's current small-plugin structure: Flutter owns state and fallback UI; iOS owns UIKit/SwiftUI rendering and native presentation only where explicitly selected by policy. Add small shared bridge utilities only where they remove duplicated lifecycle/channel logic or prevent schema drift.

**Tech Stack:** Flutter/Dart, UIKit `FlutterPlatformView`, SwiftUI `UIHostingController`, `MethodChannel`, `UiKitView`, XCTest, Flutter widget tests, iOS Simulator.

---

## Scope And Assumptions

Target platforms:
- iOS is the critical native platform.
- Android/desktop/web use Flutter fallbacks and must not regress.

Reviewed modules to fix:
- Dart controls in `lib/src/controls/`
- Dart navigation/scaffold in `lib/src/navigation/` and `lib/src/scaffolds/`
- Dart platform bridge in `lib/src/platform/`
- Swift platform views in `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/`
- Swift overlay presenter in `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Overlays/`
- README and tests.

Current background execution status:
- No background workers, isolates, BGTaskScheduler, background URLSession, push-triggered work, or app extensions exist in this package.
- The fix is to document that posture and add a guardrail test/review section, not to introduce background infrastructure.

Release risk:
- High enough to require native lifecycle checks and simulator verification before considering the bridge stable.

---

## File Structure

Create:
- `lib/src/platform/liquid_glass_native_view_channel.dart`  
  Shared Dart helper for native view method-channel lifecycle, configuration signature caching, and mounted-safe sync.
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Surfaces/LiquidGlassHostingContainer.swift`  
  UIKit container view controller helper for correct SwiftUI child containment.
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Navigation/LiquidGlassNavigationBarFactory.swift`  
  Native app-bar platform-view factory.
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Navigation/LiquidGlassNavigationBarPlatformView.swift`  
  UIKit `UINavigationBar` bridge.
- `lib/src/navigation/liquid_glass_native_app_bar.dart`  
  Dart wrapper for the native iOS navigation bar.
- `test/liquid_glass_native_lifecycle_test.dart`  
  Widget tests for inherited-theme resync and channel cleanup behavior.
- `docs/ARCHITECTURE.md`  
  Architecture map, platform policy, background-execution posture, and verification requirements.

Modify:
- `lib/native_liquid_glass_flutter.dart`
- `lib/src/controls/liquid_glass_slider.dart`
- `lib/src/controls/liquid_glass_switch.dart`
- `lib/src/controls/liquid_glass_segmented_control.dart`
- `lib/src/controls/liquid_glass_stepper.dart`
- `lib/src/controls/liquid_glass_menu_button.dart`
- `lib/src/navigation/liquid_glass_app_bar.dart`
- `lib/src/navigation/liquid_glass_tab_bar.dart`
- `lib/src/platform/liquid_glass_platform.dart`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSliderPlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSwitchPlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSegmentedControlPlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassStepperPlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassMenuButtonPlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Surfaces/LiquidGlassSurfacePlatformView.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Models/LiquidGlassViewTypes.swift`
- `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/NativeLiquidGlassFlutterPlugin.swift`
- `example/ios/RunnerTests/RunnerTests.swift`
- `test/liquid_glass_widgets_test.dart`
- `example/test/widget_test.dart`
- `README.md`

---

## Task 1: Add Swift MethodChannel Cleanup To Every Platform View

**Files:**
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Surfaces/LiquidGlassSurfacePlatformView.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSliderPlatformView.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSwitchPlatformView.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassSegmentedControlPlatformView.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassStepperPlatformView.swift`
- Verify existing: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Controls/LiquidGlassMenuButtonPlatformView.swift`
- Verify existing: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Navigation/LiquidGlassTabBarPlatformView.swift`

- [ ] **Step 1: Add cleanup to surface platform view**

Add this method inside `LiquidGlassSurfacePlatformView`:

```swift
deinit {
  channel.setMethodCallHandler(nil)
}
```

- [ ] **Step 2: Add cleanup to slider platform view**

Add this method inside `LiquidGlassSliderPlatformView`:

```swift
deinit {
  channel.setMethodCallHandler(nil)
}
```

- [ ] **Step 3: Add cleanup to switch platform view**

Add this method inside `LiquidGlassSwitchPlatformView`:

```swift
deinit {
  channel.setMethodCallHandler(nil)
}
```

- [ ] **Step 4: Add cleanup to segmented control platform view**

Add this method inside `LiquidGlassSegmentedControlPlatformView`:

```swift
deinit {
  channel.setMethodCallHandler(nil)
}
```

- [ ] **Step 5: Add cleanup to stepper platform view**

Add this method inside `LiquidGlassStepperPlatformView`:

```swift
deinit {
  channel.setMethodCallHandler(nil)
}
```

- [ ] **Step 6: Run iOS host tests**

Run:

```bash
xcodebuild test -workspace Runner.xcworkspace -quiet -scheme Runner -destination id=2C2F2E98-19C2-40CA-AB42-FDB05082AF56 -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 -parallel-testing-worker-count 1 -only-testing:RunnerTests
```

Working directory:

```text
/Users/yaser/Documents/FlutterDev/native_liquid_glass_flutter/example/ios
```

Expected: command exits `0`.

---

## Task 2: Fix SwiftUI Surface View-Controller Containment

**Files:**
- Create: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Surfaces/LiquidGlassHostingContainer.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Surfaces/LiquidGlassSurfacePlatformView.swift`
- Test: `example/ios/RunnerTests/RunnerTests.swift`

- [ ] **Step 1: Add a reusable hosting container**

Create `LiquidGlassHostingContainer.swift`:

```swift
import SwiftUI
import UIKit

final class LiquidGlassHostingContainer<Content: View>: UIViewController {
  private var hostingController: UIHostingController<Content>?

  func install(rootView: Content, in containerView: UIView, isDark: Bool) {
    if let hostingController {
      hostingController.rootView = rootView
      configure(view: hostingController.view, isDark: isDark)
      return
    }

    let hostingController = UIHostingController(rootView: rootView)
    addChild(hostingController)
    configure(view: hostingController.view, isDark: isDark)
    containerView.addSubview(hostingController.view)
    hostingController.view.frame = containerView.bounds
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingController.didMove(toParent: self)
    self.hostingController = hostingController
  }

  func uninstall() {
    guard let hostingController else {
      return
    }

    hostingController.willMove(toParent: nil)
    hostingController.view.removeFromSuperview()
    hostingController.removeFromParent()
    self.hostingController = nil
  }

  private func configure(view: UIView, isDark: Bool) {
    view.isOpaque = false
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.overrideUserInterfaceStyle = isDark ? .dark : .light
  }
}
```

- [ ] **Step 2: Replace raw hosting-controller storage**

In `LiquidGlassSurfacePlatformView`, replace:

```swift
private var hostingController: UIViewController?
```

with:

```swift
private let hostingContainer = LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>()
```

- [ ] **Step 3: Use containment in `updateLiquidGlass`**

Replace the existing `updateLiquidGlass(configuration:)` body with:

```swift
@available(iOS 26.0, *)
private func updateLiquidGlass(
  configuration: LiquidGlassSurfaceConfiguration
) {
  containerView.subviews.forEach { $0.removeFromSuperview() }
  hostingContainer.install(
    rootView: LiquidGlassSwiftUISurface(configuration: configuration),
    in: containerView,
    isDark: configuration.isDark
  )
}
```

- [ ] **Step 4: Uninstall SwiftUI hosting when falling back**

At the start of `installFallbackMaterial(configuration:)`, add:

```swift
hostingContainer.uninstall()
```

- [ ] **Step 5: Add a containment unit test**

Add to `example/ios/RunnerTests/RunnerTests.swift`:

```swift
func testHostingContainerInstallsChildController() {
  if #available(iOS 26.0, *) {
    let container = LiquidGlassHostingContainer<LiquidGlassSwiftUISurface>()
    let hostView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
    let configuration = LiquidGlassSurfaceConfiguration(arguments: [
      "cornerRadius": 22,
      "role": "chrome",
      "isDark": false
    ])

    container.install(
      rootView: LiquidGlassSwiftUISurface(configuration: configuration),
      in: hostView,
      isDark: false
    )

    XCTAssertEqual(container.children.count, 1)
    XCTAssertEqual(hostView.subviews.count, 1)

    container.uninstall()

    XCTAssertEqual(container.children.count, 0)
    XCTAssertEqual(hostView.subviews.count, 0)
  }
}
```

- [ ] **Step 6: Run iOS host tests**

Run the same `xcodebuild test` command from Task 1.

Expected: command exits `0`.

---

## Task 3: Add Shared Dart Native View Channel Lifecycle Helper

**Files:**
- Create: `lib/src/platform/liquid_glass_native_view_channel.dart`
- Modify: native-control state classes in `lib/src/controls/`
- Modify: `lib/src/navigation/liquid_glass_tab_bar.dart`
- Test: `test/liquid_glass_native_lifecycle_test.dart`

- [ ] **Step 1: Create the helper**

Create `lib/src/platform/liquid_glass_native_view_channel.dart`:

```dart
import 'package:flutter/services.dart';

class LiquidGlassNativeViewChannel {
  LiquidGlassNativeViewChannel({required this.nameForViewId});

  final String Function(int viewId) nameForViewId;
  MethodChannel? _channel;
  String? _lastSignature;

  bool get isAttached => _channel != null;

  void attach(
    int viewId, {
    required Future<void> Function(MethodCall call) handler,
  }) {
    detach();
    _channel = MethodChannel(nameForViewId(viewId));
    _channel?.setMethodCallHandler(handler);
    _lastSignature = null;
  }

  void detach() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _lastSignature = null;
  }

  Future<void> sync(
    Map<String, Object?> configuration, {
    bool force = false,
    String method = 'setConfiguration',
    String? signature,
  }) async {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    final nextSignature = signature ?? configuration.toString();
    if (!force && nextSignature == _lastSignature) {
      return;
    }

    _lastSignature = nextSignature;
    await channel.invokeMethod<void>(method, configuration);
  }

  Future<void> invoke(String method, Object? arguments) async {
    await _channel?.invokeMethod<void>(method, arguments);
  }
}
```

- [ ] **Step 2: Use the helper in `LiquidGlassMenuButtonState` first**

Replace menu button's direct `MethodChannel? channel` field with:

```dart
late final LiquidGlassNativeViewChannel channel =
    LiquidGlassNativeViewChannel(
  nameForViewId: (viewId) =>
      '${LiquidGlassPlatform.menuButtonChannelPrefix}/$viewId',
);
```

Update lifecycle methods:

```dart
void configureChannel(int viewId) {
  channel.attach(viewId, handler: handleMethodCall);
  syncConfiguration(force: true);
}

void clearChannel() {
  channel.detach();
  lastNativeValue = null;
}

void syncConfiguration({bool force = false}) {
  channel.sync(platformConfiguration(), force: force);
}
```

- [ ] **Step 3: Apply the helper to slider/switch/segmented/stepper/tab bar**

For each state class:
- Replace direct `MethodChannel? channel` with `LiquidGlassNativeViewChannel`.
- Keep the existing public `handleMethodCall` methods because tests call them.
- Keep per-control native echo fields.
- Ensure `configureChannel` calls `syncConfiguration(force: true)` after attach.
- Ensure `dispose` calls `clearChannel()`.

- [ ] **Step 4: Run analyzer**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter analyze
```

Expected: `No issues found`.

---

## Task 4: Resync All Native Controls On Inherited Dependency Changes

**Files:**
- Modify: `lib/src/controls/liquid_glass_slider.dart`
- Modify: `lib/src/controls/liquid_glass_switch.dart`
- Modify: `lib/src/controls/liquid_glass_segmented_control.dart`
- Modify: `lib/src/controls/liquid_glass_stepper.dart`
- Modify: `test/liquid_glass_native_lifecycle_test.dart`

- [ ] **Step 1: Add failing theme-resync test for slider**

Create `test/liquid_glass_native_lifecycle_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  testWidgets('native slider resyncs when inherited theme changes', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('native_liquid_glass_flutter/slider_1'),
      (call) async {
        calls.add(call);
        return null;
      },
    );

    try {
      Widget build(Color seedColor) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          ),
          home: LiquidGlassTheme(
            data: LiquidGlassThemeData.fromColorScheme(
              ColorScheme.fromSeed(seedColor: seedColor),
            ),
            child: Scaffold(
              body: LiquidGlassSlider(
                value: 0.5,
                nativePolicy: LiquidGlassNativePolicy.native,
                onChanged: (_) {},
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(build(Colors.teal));
      final state = tester.state<LiquidGlassSliderState>(
        find.byType(LiquidGlassSlider),
      );
      state.configureChannel(1);
      await tester.pump();

      await tester.pumpWidget(build(Colors.pink));
      await tester.pump();

      final setConfigurationCalls = calls
          .where((call) => call.method == 'setConfiguration')
          .toList();
      expect(setConfigurationCalls.length, greaterThanOrEqualTo(2));
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('native_liquid_glass_flutter/slider_1'),
        null,
      );
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
```

- [ ] **Step 2: Run the new test and verify it fails before implementation**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test test/liquid_glass_native_lifecycle_test.dart
```

Expected before implementation: failure because only one `setConfiguration` call is sent.

- [ ] **Step 3: Add `didChangeDependencies` to each native control state**

Add this to `LiquidGlassSliderState`, `LiquidGlassSwitchState`, `LiquidGlassSegmentedControlState`, and `LiquidGlassStepperState`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (usesNativeView) {
    syncConfiguration();
  }
}
```

- [ ] **Step 4: Add `syncConfiguration` methods where missing**

Each control should use:

```dart
void syncConfiguration({bool force = false}) {
  channel.sync(platformConfiguration(), force: force);
}
```

If Task 3 is not complete yet, use:

```dart
void syncConfiguration({bool force = false}) {
  final channel = this.channel;
  if (channel == null) {
    return;
  }

  final configuration = platformConfiguration();
  final signature = configuration.toString();
  if (!force && signature == lastConfigurationSignature) {
    return;
  }

  lastConfigurationSignature = signature;
  channel.invokeMethod<void>('setConfiguration', configuration);
}
```

- [ ] **Step 5: Add equivalent tests for switch, segmented, and stepper**

Use the same structure as the slider test with these channel names:

```dart
const MethodChannel('native_liquid_glass_flutter/switch_1')
const MethodChannel('native_liquid_glass_flutter/segmented_1')
const MethodChannel('native_liquid_glass_flutter/stepper_1')
```

Expected: at least two `setConfiguration` calls after theme change.

- [ ] **Step 6: Run lifecycle tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test test/liquid_glass_native_lifecycle_test.dart
```

Expected: all tests pass.

---

## Task 5: Add Native iOS Navigation Bar Bridge

**Files:**
- Create: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Navigation/LiquidGlassNavigationBarFactory.swift`
- Create: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Navigation/LiquidGlassNavigationBarPlatformView.swift`
- Create: `lib/src/navigation/liquid_glass_native_app_bar.dart`
- Modify: `lib/src/navigation/liquid_glass_app_bar.dart`
- Modify: `lib/src/platform/liquid_glass_platform.dart`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Models/LiquidGlassViewTypes.swift`
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/NativeLiquidGlassFlutterPlugin.swift`
- Modify: `lib/native_liquid_glass_flutter.dart`
- Test: `test/liquid_glass_widgets_test.dart`
- Test: `example/ios/RunnerTests/RunnerTests.swift`

- [ ] **Step 1: Add platform constants**

In `LiquidGlassPlatform`, add:

```dart
static const String navigationBarViewType =
    'native_liquid_glass_flutter/liquid_glass_navigation_bar';
static const String navigationBarChannelPrefix =
    'native_liquid_glass_flutter/navigation_bar';
```

In `LiquidGlassViewTypes.swift`, add:

```swift
static let navigationBar = "native_liquid_glass_flutter/liquid_glass_navigation_bar"
```

- [ ] **Step 2: Register the factory**

In `NativeLiquidGlassFlutterPlugin.register`, add:

```swift
registrar.register(
  LiquidGlassNavigationBarFactory(messenger: registrar.messenger()),
  withId: LiquidGlassViewTypes.navigationBar
)
```

- [ ] **Step 3: Create the Swift factory**

Create `LiquidGlassNavigationBarFactory.swift`:

```swift
import Flutter
import UIKit

final class LiquidGlassNavigationBarFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return LiquidGlassNavigationBarPlatformView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}
```

- [ ] **Step 4: Create native navigation bar platform view**

Create `LiquidGlassNavigationBarPlatformView.swift` with:

```swift
import Flutter
import UIKit

final class LiquidGlassNavigationBarPlatformView:
  NSObject, FlutterPlatformView, UINavigationBarDelegate
{
  private let containerView: UIView
  private let navigationBar: UINavigationBar
  private let backNavigationItem = UINavigationItem(title: "")
  private let navigationItem = UINavigationItem(title: "")
  private let channel: FlutterMethodChannel
  private var canGoBack = false
  private var isRtl = false

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    self.containerView = UIView(frame: frame)
    self.navigationBar = UINavigationBar(frame: .zero)
    self.channel = FlutterMethodChannel(
      name: "native_liquid_glass_flutter/navigation_bar/\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.delegate = self
    containerView.addSubview(navigationBar)
    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      navigationBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      navigationBar.heightAnchor.constraint(equalToConstant: 44),
    ])

    configure(arguments: arguments)
    channel.setMethodCallHandler(handle)
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

  private func configure(arguments: Any?) {
    let map = arguments as? [String: Any] ?? [:]
    canGoBack = Self.bool(from: map["canGoBack"]) ?? false
    isRtl = Self.bool(from: map["isRtl"]) ?? false
    let isDark = Self.bool(from: map["isDark"]) ?? false
    let title = map["title"] as? String
    let foregroundColor = LiquidGlassSurfaceConfiguration.color(
      from: map["foregroundColor"] as? NSNumber
    )
    let backgroundColor = LiquidGlassSurfaceConfiguration.color(
      from: map["backgroundColor"] as? NSNumber
    )

    containerView.backgroundColor = backgroundColor
    containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
    containerView.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    navigationBar.isTranslucent = true
    navigationBar.tintColor = foregroundColor
    navigationBar.prefersLargeTitles = false
    navigationBar.overrideUserInterfaceStyle = isDark ? .dark : .light
    navigationBar.semanticContentAttribute = isRtl
      ? .forceRightToLeft
      : .forceLeftToRight

    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
    appearance.backgroundColor = backgroundColor.withAlphaComponent(isDark ? 0.86 : 0.78)
    appearance.shadowColor = UIColor.separator.withAlphaComponent(0.45)
    appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
    navigationBar.standardAppearance = appearance
    navigationBar.compactAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    if #available(iOS 15.0, *) {
      navigationBar.compactScrollEdgeAppearance = appearance
    }

    navigationItem.title = title
    backNavigationItem.title = ""
    backNavigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )
    if #available(iOS 14.0, *) {
      backNavigationItem.backButtonDisplayMode = .minimal
    }

    navigationBar.setItems(
      canGoBack ? [backNavigationItem, navigationItem] : [navigationItem],
      animated: false
    )
  }

  func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
    if item === navigationItem {
      channel.invokeMethod("onBack", arguments: nil)
      return false
    }
    return true
  }

  private static func bool(from value: Any?) -> Bool? {
    if let bool = value as? Bool {
      return bool
    }
    if let number = value as? NSNumber {
      return number.boolValue
    }
    return nil
  }
}
```

- [ ] **Step 5: Add Dart wrapper**

Create `lib/src/navigation/liquid_glass_native_app_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassNativeAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const LiquidGlassNativeAppBar({
    super.key,
    this.title,
    this.height,
    this.canGoBack = false,
    this.onBack,
  });

  static const double navigationBarHeight = 44;

  final String? title;
  final double? height;
  final bool canGoBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(height ?? navigationBarHeight);

  @override
  State<LiquidGlassNativeAppBar> createState() => _LiquidGlassNativeAppBarState();
}

class _LiquidGlassNativeAppBarState extends State<LiquidGlassNativeAppBar> {
  MethodChannel? channel;
  String? lastSignature;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncConfiguration();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNativeAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfiguration(force: true);
  }

  @override
  void dispose() {
    channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: widget.height ?? LiquidGlassNativeAppBar.navigationBarHeight,
        child: UiKitView(
          viewType: LiquidGlassPlatform.navigationBarViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
          onPlatformViewCreated: configureChannel,
        ),
      ),
    );
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);
    final materialTheme = Theme.of(context);
    return <String, Object?>{
      'title': widget.title,
      'canGoBack': widget.canGoBack,
      'foregroundColor': theme.foregroundColor.toARGB32(),
      'backgroundColor': materialTheme.colorScheme.surface.toARGB32(),
      'isRtl': Directionality.of(context) == TextDirection.rtl,
      'isDark': materialTheme.brightness == Brightness.dark,
      'locale': Localizations.localeOf(context).toLanguageTag(),
    };
  }

  void configureChannel(int viewId) {
    channel?.setMethodCallHandler(null);
    channel = MethodChannel(
      '${LiquidGlassPlatform.navigationBarChannelPrefix}/$viewId',
    );
    channel?.setMethodCallHandler(handleMethodCall);
    syncConfiguration(force: true);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onBack') {
      widget.onBack?.call();
    }
  }

  void syncConfiguration({bool force = false}) {
    final channel = this.channel;
    if (channel == null) {
      return;
    }
    final configuration = platformConfiguration();
    final signature = configuration.toString();
    if (!force && signature == lastSignature) {
      return;
    }
    lastSignature = signature;
    channel.invokeMethod<void>('setConfiguration', configuration);
  }
}
```

- [ ] **Step 6: Make `LiquidGlassAppBar` select native app bar on iOS**

In `LiquidGlassAppBar.build`, before the Flutter fallback return:

```dart
if (LiquidGlassPlatform.isNativeIOS) {
  return LiquidGlassNativeAppBar(
    title: title is Text ? (title as Text).data : null,
    height: height,
    canGoBack: resolvedLeading != null,
    onBack: () => Navigator.of(context).maybePop(),
  );
}
```

Add imports:

```dart
import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_native_app_bar.dart';
```

- [ ] **Step 7: Export the wrapper**

Add to `lib/native_liquid_glass_flutter.dart`:

```dart
export 'src/navigation/liquid_glass_native_app_bar.dart';
```

- [ ] **Step 8: Add widget test**

Add to `test/liquid_glass_widgets_test.dart`:

```dart
testWidgets('app bar uses native navigation bar view on iOS', (tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  try {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: LiquidGlassAppBar(title: Text('Native')),
          body: SizedBox.shrink(),
        ),
      ),
    );

    final view = tester.widget<UiKitView>(find.byType(UiKitView));
    expect(view.viewType, LiquidGlassPlatform.navigationBarViewType);
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
});
```

- [ ] **Step 9: Run tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test test/liquid_glass_widgets_test.dart
xcodebuild test -workspace Runner.xcworkspace -quiet -scheme Runner -destination id=2C2F2E98-19C2-40CA-AB42-FDB05082AF56 -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 -parallel-testing-worker-count 1 -only-testing:RunnerTests
```

Expected: both commands exit `0`.

---

## Task 6: Harden Platform-Channel Contracts

**Files:**
- Create or modify: `lib/src/platform/liquid_glass_bridge_keys.dart`
- Modify: `lib/src/platform/liquid_glass_platform.dart`
- Modify: `lib/src/navigation/liquid_glass_tab_bar.dart`
- Modify: `lib/src/controls/liquid_glass_menu_button.dart`
- Modify: all native-control Dart config maps.
- Modify: Swift parser files as needed.
- Test: `test/liquid_glass_platform_test.dart`
- Test: `example/ios/RunnerTests/RunnerTests.swift`

- [ ] **Step 1: Create Dart key constants**

Create `lib/src/platform/liquid_glass_bridge_keys.dart`:

```dart
abstract final class LiquidGlassBridgeKeys {
  static const actions = 'actions';
  static const activeColor = 'activeColor';
  static const backgroundColor = 'backgroundColor';
  static const cancelTitle = 'cancelTitle';
  static const confirmTitle = 'confirmTitle';
  static const enabled = 'enabled';
  static const foregroundColor = 'foregroundColor';
  static const inactiveColor = 'inactiveColor';
  static const initialDate = 'initialDate';
  static const initialMinutes = 'initialMinutes';
  static const isDark = 'isDark';
  static const isRtl = 'isRtl';
  static const items = 'items';
  static const locale = 'locale';
  static const max = 'max';
  static const maximumDate = 'maximumDate';
  static const message = 'message';
  static const min = 'min';
  static const minimumDate = 'minimumDate';
  static const minuteInterval = 'minuteInterval';
  static const selectedColor = 'selectedColor';
  static const selectedIndex = 'selectedIndex';
  static const segments = 'segments';
  static const step = 'step';
  static const tintColor = 'tintColor';
  static const title = 'title';
  static const value = 'value';
}

abstract final class LiquidGlassBridgeMethods {
  static const getPlatformVersion = 'getPlatformVersion';
  static const onBack = 'onBack';
  static const onChanged = 'onChanged';
  static const onChangeEnd = 'onChangeEnd';
  static const onTap = 'onTap';
  static const setConfiguration = 'setConfiguration';
  static const setSelectedIndex = 'setSelectedIndex';
  static const showActionSheet = 'showActionSheet';
  static const showAlert = 'showAlert';
  static const showDatePicker = 'showDatePicker';
  static const showOptionPicker = 'showOptionPicker';
  static const showShareSheet = 'showShareSheet';
  static const showTimePicker = 'showTimePicker';
}
```

- [ ] **Step 2: Replace Dart string literals**

Replace bridge key/method string literals in Dart with constants from `LiquidGlassBridgeKeys` and `LiquidGlassBridgeMethods`.

- [ ] **Step 3: Add platform contract tests**

In `test/liquid_glass_platform_test.dart`, add one test per method that asserts exact method names and required keys. Example:

```dart
test('alert sends stable bridge keys', () async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  MethodCall? receivedCall;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
    receivedCall = call;
    return 'ok';
  });

  try {
    await const LiquidGlassPlatform().showAlert(
      title: 'Title',
      message: 'Message',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'OK', value: 'ok'),
      ],
    );

    expect(receivedCall?.method, LiquidGlassBridgeMethods.showAlert);
    expect(receivedCall?.arguments, containsPair('title', 'Title'));
    expect(receivedCall?.arguments, containsPair('message', 'Message'));
    expect(receivedCall?.arguments, contains('actions'));
  } finally {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, null);
    debugDefaultTargetPlatformOverride = null;
  }
});
```

- [ ] **Step 4: Add Swift parser tests**

In `RunnerTests.swift`, add tests that invalid argument maps do not crash and normalize correctly:

```swift
func testSurfaceConfigurationHandlesMissingValues() {
  let configuration = LiquidGlassSurfaceConfiguration(arguments: [:])

  XCTAssertEqual(configuration.cornerStyle, "all")
  XCTAssertFalse(configuration.isDark)
}
```

- [ ] **Step 5: Run tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test test/liquid_glass_platform_test.dart
```

Expected: all tests pass.

---

## Task 7: Formalize Overlay Lifecycle And Cancellation Policy

**Files:**
- Modify: `ios/native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/Overlays/LiquidGlassPresenter.swift`
- Modify: `lib/src/overlays/liquid_glass_action_sheet.dart`
- Modify: `lib/src/overlays/liquid_glass_dialog.dart`
- Modify: `lib/src/overlays/liquid_glass_date_picker.dart`
- Modify: `lib/src/overlays/liquid_glass_time_picker.dart`
- Modify: `lib/src/overlays/liquid_glass_option_picker.dart`
- Modify: `lib/src/overlays/liquid_glass_share_sheet.dart`
- Test: `test/liquid_glass_widgets_test.dart`
- Test: `example/ios/RunnerTests/RunnerTests.swift`

- [ ] **Step 1: Define overlay result model behavior in docs**

Document in README and `docs/ARCHITECTURE.md`:

```text
Native overlays complete with:
- selected value for user action
- null for user cancellation/dismissal
- PlatformException for native presentation failure

Flutter wrappers must catch PlatformException and use fallback UI when the BuildContext is still mounted.
```

- [ ] **Step 2: Add a presenter cancellation method**

In `LiquidGlassPresenter`, add:

```swift
func cancelPresentedOverlay(result: @escaping FlutterResult) {
  guard Thread.isMainThread else {
    DispatchQueue.main.async { [weak self] in
      self?.cancelPresentedOverlay(result: result)
    }
    return
  }

  guard let viewController = topViewController(),
    viewController is UIAlertController || viewController is UIActivityViewController
  else {
    result(false)
    return
  }

  viewController.dismiss(animated: true) {
    result(true)
  }
}
```

- [ ] **Step 3: Expose cancellation method on plugin channel**

In `NativeLiquidGlassFlutterPlugin.handle`, add:

```swift
case "cancelPresentedOverlay":
  presenter.cancelPresentedOverlay(result: result)
```

In `LiquidGlassPlatform`, add:

```dart
Future<bool?> cancelPresentedOverlay() async {
  if (!isNativeIOS) {
    return null;
  }

  return channel.invokeMethod<bool>('cancelPresentedOverlay');
}
```

- [ ] **Step 4: Add tests for native presentation busy fallback**

Keep existing fallback tests and add one test for cancellation method:

```dart
test('cancel overlay calls native channel on iOS', () async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  MethodCall? receivedCall;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
    receivedCall = call;
    return true;
  });

  try {
    final cancelled = await const LiquidGlassPlatform().cancelPresentedOverlay();
    expect(cancelled, true);
    expect(receivedCall?.method, 'cancelPresentedOverlay');
  } finally {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, null);
    debugDefaultTargetPlatformOverride = null;
  }
});
```

- [ ] **Step 5: Run overlay tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test test/liquid_glass_widgets_test.dart test/liquid_glass_platform_test.dart
```

Expected: all tests pass.

---

## Task 8: Add Architecture Documentation And Background Execution Guardrails

**Files:**
- Create: `docs/ARCHITECTURE.md`
- Modify: `README.md`

- [ ] **Step 1: Create architecture document**

Create `docs/ARCHITECTURE.md`:

```markdown
# Native Liquid Glass Flutter Architecture

## Scope

This package is a UI plugin. It does not own app domain state, persistence,
networking, background workers, push handling, or offline sync.

## Dependency Direction

Flutter widgets own:
- public package API
- component state
- fallback UI
- routing callbacks
- platform configuration maps

iOS native code owns:
- UIKit and SwiftUI rendering for opted-in native surfaces/controls
- native overlay presentation
- native tab bar and navigation bar layout

Native code must not own app domain state or routing.

## Native Policy

`LiquidGlassNativePolicy.automatic` keeps content and controls in Flutter,
while allowing chrome, floating surfaces, and modals to use native iOS
rendering. Explicit `native` policy is required for native iOS controls.

## Bridge Contracts

All `MethodChannel` method names and map keys are part of the public bridge
contract. Every new key or method must be covered by:
- Dart platform contract test
- Swift parser/unit test where parsing is non-trivial
- iOS host build

## Lifecycle Rules

Every Swift platform view that installs a method handler must clear it in
`deinit`. Every Dart native wrapper must clear handlers in `dispose`.

Native wrappers whose configuration depends on inherited Flutter state must
sync in `didChangeDependencies` and `didUpdateWidget`.

## Background Execution

This package does not schedule background work. It does not use:
- BGTaskScheduler
- background URLSession
- push-triggered execution
- app extensions
- Flutter isolates

If background work is added later, it must be designed as a separate subsystem
with explicit cancellation, retry, permission, App Store policy, and plugin
registration tests.

## Verification Gates

Before release:
- `dart format --set-exit-if-changed lib test example/lib example/test`
- `flutter analyze`
- package widget/unit tests
- example widget tests
- iOS `xcodebuild test`
- simulator smoke test for native controls and overlays
- leak/performance pass for repeated platform-view creation/disposal
```

- [ ] **Step 2: Link architecture doc from README**

Add near README architecture section:

```markdown
For lifecycle rules, dependency direction, bridge contracts, and background
execution posture, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
```

---

## Task 9: Add Native Lifecycle And Smoke Verification Coverage

**Files:**
- Modify: `test/liquid_glass_widgets_test.dart`
- Modify: `test/liquid_glass_native_lifecycle_test.dart`
- Modify: `example/test/widget_test.dart`
- Modify: `example/ios/RunnerTests/RunnerTests.swift`

- [ ] **Step 1: Add widget test for native menu inherited config**

Add:

```dart
testWidgets('native menu button resyncs when inherited theme changes', (
  tester,
) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  final calls = <MethodCall>[];
  const channel = MethodChannel('native_liquid_glass_flutter/menu_button/1');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    calls.add(call);
    return null;
  });

  try {
    Widget build(Color seedColor) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        ),
        home: LiquidGlassTheme(
          data: LiquidGlassThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: seedColor),
          ),
          child: Scaffold(
            body: LiquidGlassMenuButton(
              title: 'Density',
              value: 'compact',
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Compact', value: 'compact'),
                LiquidGlassAction(title: 'Comfortable', value: 'comfortable'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(build(Colors.teal));
    final state = tester.state<LiquidGlassMenuButtonState>(
      find.byType(LiquidGlassMenuButton),
    );
    state.configureChannel(1);
    await tester.pumpWidget(build(Colors.pink));
    await tester.pump();

    expect(
      calls.where((call) => call.method == 'setConfiguration').length,
      greaterThanOrEqualTo(2),
    );
  } finally {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  }
});
```

- [ ] **Step 2: Add Swift parser and platform utility tests**

In `RunnerTests.swift`, add tests for:
- action list normalization
- slider coordinator snapping
- surface corner style
- navigation bar configuration parsing after Task 5
- hosting container containment after Task 2

Use existing `RunnerTests` style and avoid UI presentation in unit tests.

- [ ] **Step 3: Add manual smoke checklist to docs**

Add to `docs/ARCHITECTURE.md`:

```markdown
## Manual Simulator Smoke Checklist

- Native slider drags with cursor/finger and emits live values.
- Native switch toggles once per tap.
- Native segmented control changes once per segment tap.
- Native stepper clamps min/max.
- Native tab bar uses OS icon/label spacing and stays bottom-pinned.
- Native menu opens as a `UIMenu` and updates Flutter state.
- Alert/action sheet/date/time/share overlays return expected values.
- Theme switch updates mounted native controls.
- RTL flips directional chrome.
- Dynamic Type does not clip tab/menu/app-bar labels.
- Keyboard hides bottom chrome when configured.
- App background/foreground does not leave dangling overlays.
```

---

## Task 10: Final Verification Gate

**Files:**
- All changed files.

- [ ] **Step 1: Format check**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/dart format --set-exit-if-changed lib test example/lib example/test
```

Expected: `Formatted ... (0 changed)` and exit `0`.

- [ ] **Step 2: Analyze**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Package tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test
```

Working directory:

```text
/Users/yaser/Documents/FlutterDev/native_liquid_glass_flutter
```

Expected: all tests pass.

- [ ] **Step 4: Example tests**

Run:

```bash
/Users/yaser/fvm/versions/3.44.0/bin/flutter test
```

Working directory:

```text
/Users/yaser/Documents/FlutterDev/native_liquid_glass_flutter/example
```

Expected: all tests pass.

- [ ] **Step 5: iOS host tests**

Run:

```bash
xcodebuild test -workspace Runner.xcworkspace -quiet -scheme Runner -destination id=2C2F2E98-19C2-40CA-AB42-FDB05082AF56 -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 -parallel-testing-worker-count 1 -only-testing:RunnerTests
```

Working directory:

```text
/Users/yaser/Documents/FlutterDev/native_liquid_glass_flutter/example/ios
```

Expected: command exits `0`.

- [ ] **Step 6: Manual simulator smoke**

Run the example app on the current simulator and execute the checklist from Task 9.

Capture screenshots:

```bash
xcrun simctl io 2C2F2E98-19C2-40CA-AB42-FDB05082AF56 screenshot /private/tmp/native-liquid-glass-architecture-final.png
```

Expected: tab bar is native-spaced and bottom-pinned; overlay/native menu showcase is reachable and functional.

---

## Self-Review

Spec coverage:
- P1 MethodChannel cleanup: Task 1.
- P1 SwiftUI containment: Task 2.
- P1 native app bar parity with Zakr: Task 5.
- P2 inherited dependency resync: Task 3 and Task 4.
- P2 bridge contract drift: Task 6.
- Overlay lifecycle/cancellation: Task 7.
- Missing architecture/background docs: Task 8.
- Testing and verification gaps: Task 9 and Task 10.

Placeholder scan:
- No task uses TBD/TODO/later language.
- Every task lists files, commands, and expected outputs.

Type consistency:
- `LiquidGlassNativeViewChannel`, `LiquidGlassNativeAppBar`, `LiquidGlassBridgeKeys`, and `LiquidGlassBridgeMethods` are defined before use.
- Channel prefixes and view types match the existing package naming style.
