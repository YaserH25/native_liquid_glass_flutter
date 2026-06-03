# native_liquid_glass_flutter

Native iOS Liquid Glass surfaces, system overlays, and adaptive Flutter
fallbacks for apps that need an iOS-native feel without forcing that design onto
Android.

The package is a Flutter plugin because the iOS implementation uses Swift code:

- iOS 26 and newer: SwiftUI Liquid Glass through `glassEffect`.
- iOS 13 through iOS 25: UIKit `UIVisualEffectView` material fallback.
- Android, desktop, web, and tests: Flutter-rendered superellipse glass fallback.

By default, regular content and controls stay in Flutter. Native iOS surfaces are
used automatically for chrome, floating surfaces, and modals, or anywhere you
explicitly opt in with `LiquidGlassNativePolicy.native`.

The example app is a component gallery. It covers surfaces, navigation, live
sliders, switches, segmented controls, steppers, menus, pull-down buttons,
sheets, alerts, action sheets, option pickers, date/time pickers, share sheets,
and configuration changes.

## Why This Package

Most Flutter glass packages are visual effects. They wrap widgets with
`BackdropFilter`, custom painters, or shaders to approximate glass, blur,
refraction, droplets, or Liquid Glass-style highlights. That is useful for
decorative cards and cross-platform effects, but it does not make iOS own the
controls, menus, safe areas, modal presenters, accessibility behavior, or system
chrome.

`native_liquid_glass_flutter` is built for apps that want Flutter to keep app
state while iOS renders the surfaces and controls that should feel native.

| Need | Visual-only glass packages | `native_liquid_glass_flutter` |
| --- | --- | --- |
| iOS 26 Liquid Glass | Usually a Dart-rendered approximation with blur, shaders, or highlights | Uses SwiftUI `glassEffect` on iOS 26+ |
| Older iOS support | Usually the same Flutter effect on every iOS version | Uses UIKit `UIVisualEffectView` material on iOS 13-25 |
| Native iOS controls | Usually custom Flutter widgets that look glassy | Optional `UISlider`, `UISwitch`, `UISegmentedControl`, `UIStepper`, `UIButton`, `UIMenu`, and `UITabBar` |
| Native presenters | Often not included, or implemented as Flutter dialogs/sheets | `UIAlertController`, `UIDatePicker`, `UIActivityViewController`, and package glass fallbacks |
| Cross-platform behavior | Often applies the same glass language everywhere | Keeps Android, desktop, web, and tests on Flutter-rendered fallbacks |
| Flutter state ownership | Usually pure Flutter visual wrappers | Flutter remains the source of truth; native views report actions back through channels |
| Environment sync | Varies by package | Theme, direction, locale, labels, disabled state, and values resync into mounted native views |

Use this package when the goal is not just "make a frosted card," but "make an
iOS screen feel like iOS while the app remains Flutter." If you only need a
shader effect, water-droplet distortion, or a lightweight Dart-only glass card,
a visual package such as [`cupertino_liquid_glass`][cupertino-liquid-glass-pkg],
[`oc_liquid_glass`][oc-liquid-glass-pkg],
[`liquid_glass_flutter`][liquid-glass-flutter-pkg],
[`flutter_liquid_glass`][flutter-liquid-glass-pkg], or
[`glass`][glass-pkg] may be a better fit.

## Installation

```yaml
dependencies:
  native_liquid_glass_flutter: ^0.0.6
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LiquidGlassTheme(
      data: LiquidGlassThemeData.fromColorScheme(colorScheme),
      child: LiquidGlassScaffold(
        appBar: const LiquidGlassAppBar(
          center: Icon(Icons.auto_awesome_rounded),
        ),
        bottomNavigationBar: LiquidGlassTabBar(
          selectedIndex: 0,
          onSelected: (index) {},
          items: const <LiquidGlassTabItem>[
            LiquidGlassTabItem(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: Text('Home'),
              nativeSymbol: 'house',
              nativeSelectedSymbol: 'house.fill',
            ),
            LiquidGlassTabItem(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book_rounded),
              label: Text('Read'),
              nativeSymbol: 'book',
              nativeSelectedSymbol: 'book.fill',
            ),
          ],
        ),
        body: const ListView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 112),
          children: <Widget>[
            LiquidGlassSurface(
              padding: EdgeInsets.all(18),
              child: Text('Flutter content over adaptive glass.'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Component Matrix

| Component | iOS implementation | Other platforms |
| --- | --- | --- |
| `LiquidGlassSurface` | Automatic policy keeps content in Flutter and uses SwiftUI/UIKit material for chrome, floating surfaces, and modals | Flutter superellipse + blur fallback |
| `LiquidGlassTabBar` | `UITabBar` platform view for chrome, bridged to Flutter selection state | Flutter glass tab bar |
| `LiquidGlassSlider` | Flutter `Slider` by default, optional `UISlider` with `nativePolicy: LiquidGlassNativePolicy.native` | Flutter `Slider` |
| `LiquidGlassSwitch` | Flutter `Switch` by default, optional `UISwitch` with `nativePolicy: LiquidGlassNativePolicy.native` | Flutter `Switch` |
| `LiquidGlassSegmentedControl` | Flutter `SegmentedButton` by default, optional `UISegmentedControl` with native policy | Flutter `SegmentedButton` |
| `LiquidGlassStepper` | Flutter icon buttons by default, optional `UIStepper` with native policy | Flutter icon buttons |
| `LiquidGlassMenuButton` | `UIButton` with native `UIMenu` and `UIAction` items | Flutter option picker |
| `LiquidGlassPullDownButton` | `UIButton` with native `UIMenu` command actions | Flutter option picker |
| `showLiquidGlassActionSheet` | `UIAlertController.actionSheet` | Package glass bottom sheet |
| `showLiquidGlassAlert` | `UIAlertController.alert` | Package glass dialog |
| `showLiquidGlassOptionPicker` | `UIAlertController.actionSheet` | Package glass action sheet |
| `showLiquidGlassDatePicker` | `UIDatePicker` in native action sheet | Flutter `showDatePicker` |
| `showLiquidGlassTimePicker` | `UIDatePicker` in native action sheet | Flutter `showTimePicker` |
| `showLiquidGlassShareSheet` | `UIActivityViewController` | Snackbar fallback |

## Visual Tour

The README uses motion for the controls and presenters where behavior matters.
Static screenshots are kept only for layout, navigation, pickers, and menu
variants where a still frame is clearer. Regenerate the GIFs from a booted iOS
simulator with `fvm dart run tool/record_component_gifs.dart`.

### Interactions

| Component or API | Motion |
| --- | --- |
| `LiquidGlassButton` press states | ![LiquidGlassButton interaction][button-gif] |
| `LiquidGlassSlider` native drag | ![LiquidGlassSlider interaction][slider-gif] |
| `LiquidGlassSlider` endpoint symbols | ![LiquidGlassSlider endpoint interaction][slider-endpoints-gif] |
| `LiquidGlassSwitch` toggle | ![LiquidGlassSwitch interaction][switch-gif] |
| `LiquidGlassSegmentedControl` and `LiquidGlassStepper` | ![LiquidGlassSegmentedControl and LiquidGlassStepper interaction][segmented-stepper-gif] |
| `showLiquidGlassSheet` presentation | ![showLiquidGlassSheet interaction][sheet-gif] |
| `showLiquidGlassAlert` presentation | ![showLiquidGlassAlert interaction][alert-gif] |
| `showLiquidGlassActionSheet` presentation | ![showLiquidGlassActionSheet interaction][action-sheet-gif] |
| `LiquidGlassMenuButton` native `UIMenu` | ![LiquidGlassMenuButton interaction][menu-gif] |
| `LiquidGlassPullDownButton` command menu | ![LiquidGlassPullDownButton interaction][pull-down-gif] |

### Static Reference

`Directionality`, `Localizations.localeOf`, and `Theme` are sent through the
native bridge. Mounted UIKit views resync when the app changes theme, text
direction, or locale.

| Area | Screenshot |
| --- | --- |
| Environment controls | ![Environment controls][environment-img] |
| RTL and Arabic locale | ![RTL and Arabic locale][rtl-img] |
| `LiquidGlassSurface` | ![LiquidGlassSurface][surface-img] |
| `LiquidGlassAppBar` | ![LiquidGlassAppBar][app-bar-img] |
| `LiquidGlassTabBar` | ![LiquidGlassTabBar][tab-bar-img] |
| Icon action menu | ![Icon action menu][action-menu-img] |
| Grouped command menu | ![Grouped command menu][grouped-menu-img] |
| Pull-down command opening a native slider sheet | ![Pull-down slider command][pull-down-slider-img] |
| `showLiquidGlassOptionPicker` | ![showLiquidGlassOptionPicker][option-picker-img] |
| `showLiquidGlassDatePicker` | ![showLiquidGlassDatePicker][date-picker-img] |
| `showLiquidGlassTimePicker` | ![showLiquidGlassTimePicker][time-picker-img] |
| `showLiquidGlassShareSheet` | ![showLiquidGlassShareSheet][share-sheet-img] |

## Widgets

### LiquidGlassSurface

Use `LiquidGlassSurface` for app bars, bottom bars, sheets, floating controls,
and small grouped controls.

```dart
LiquidGlassSurface(
  configuration: const LiquidGlassConfiguration(
    cornerRadius: 32,
    cornerStyle: LiquidGlassCornerStyle.all,
    tintOpacity: 0.18,
    interactive: true,
  ),
  padding: const EdgeInsets.all(16),
  child: const Text('Glass content'),
)
```

### LiquidGlassAppBar

`LiquidGlassAppBar` keeps leading/back behavior directional by using Flutter's
native `BackButton`. Simple text-title app bars can stay native on iOS while
exposing trailing `UIBarButtonItem` actions back to Flutter.

```dart
LiquidGlassAppBar(
  title: const Text('Reader'),
  nativeActions: const <LiquidGlassAppBarAction>[
    LiquidGlassAppBarAction(
      title: 'Bookmark',
      value: 'bookmark',
      nativeSymbol: 'bookmark',
    ),
  ],
  onNativeActionSelected: handleAppBarAction,
)
```

### LiquidGlassTabBar

The tab bar is designed to be overlaid by `LiquidGlassScaffold`, so it does not
reserve layout height like a normal `Scaffold.bottomNavigationBar`.

```dart
LiquidGlassTabBar(
  selectedIndex: selectedIndex,
  onSelected: onTabChanged,
  iconTextGap: 6,
  items: const <LiquidGlassTabItem>[
    LiquidGlassTabItem(
      icon: Icon(Icons.home_outlined),
      label: Text('Home'),
      nativeSymbol: 'house',
      nativeSelectedSymbol: 'house.fill',
    ),
    LiquidGlassTabItem(
      icon: Icon(Icons.alarm_outlined),
      label: Text('Alerts'),
      nativeSymbol: 'alarm',
      nativeSelectedSymbol: 'alarm.fill',
      badge: '2',
    ),
    LiquidGlassTabItem(
      icon: Icon(Icons.settings_outlined),
      label: Text('Settings'),
      nativeSymbol: 'gearshape',
      enabled: false,
    ),
  ],
)
```

On iOS the tab bar is a native `UITabBar` platform view pinned by
`LiquidGlassScaffold`. Flutter still owns the selected index and routing through
`onSelected`, while the system owns the item layout, safe-area height, and SF
Symbol rendering.

### Controls And Native Opt-In

`LiquidGlassSlider`, `LiquidGlassSwitch`, `LiquidGlassSegmentedControl`, and
`LiquidGlassStepper` stay Flutter-first in automatic mode. Set
`nativePolicy: LiquidGlassNativePolicy.native` when a focused iOS screen should
use the UIKit control. Native controls keep their values in sync through
per-view method channels and eager gesture forwarding. The slider calls
`onChanged` while the thumb moves, so previews can update immediately inside
sheets. Native glass surfaces are decorative pass-through layers when Flutter
owns the controls above them.

```dart
double textScale = 1;

LiquidGlassSlider(
  value: textScale,
  min: 0.8,
  max: 1.4,
  step: 0.01,
  nativePolicy: LiquidGlassNativePolicy.native,
  minimumNativeSymbol: 'textformat.size.smaller',
  maximumNativeSymbol: 'textformat.size.larger',
  isContinuous: false,
  onChanged: (value) {
    setState(() => textScale = value);
  },
  onChangeEnd: saveTextScale,
)
```

```dart
LiquidGlassSegmentedControl(
  selectedIndex: selectedIndex,
  onChanged: (index) => setState(() => selectedIndex = index),
  segments: const <LiquidGlassSegment>[
    LiquidGlassSegment(label: 'Subtle'),
    LiquidGlassSegment(label: 'Regular'),
    LiquidGlassSegment(label: 'Bold'),
  ],
)
```

```dart
LiquidGlassSwitch(
  value: enabled,
  nativePolicy: LiquidGlassNativePolicy.native,
  onChanged: (value) => setState(() => enabled = value),
)
```

```dart
LiquidGlassStepper(
  value: count.toDouble(),
  min: 0,
  max: 10,
  nativePolicy: LiquidGlassNativePolicy.native,
  onChanged: (value) => setState(() => count = value.round()),
)
```

`LiquidGlassMenuButton` is a native iOS `UIMenu` control by default. Use it for
compact option sets where the selected value should stay visible.

```dart
LiquidGlassMenuButton(
  title: 'Density',
  value: density,
  onChanged: (value) => setState(() => density = value),
  options: const <LiquidGlassAction>[
    LiquidGlassAction(
      title: 'Compact',
      value: 'compact',
      nativeSymbol: 'rectangle.compress.vertical',
      group: 'Density',
    ),
    LiquidGlassAction(
      title: 'Comfortable',
      value: 'comfortable',
      nativeSymbol: 'rectangle.split.3x1',
      role: LiquidGlassActionRole.preferred,
      group: 'Density',
    ),
    LiquidGlassAction(
      title: 'Spacious',
      value: 'spacious',
      nativeSymbol: 'rectangle.expand.vertical',
      group: 'Density',
    ),
  ],
)
```

`LiquidGlassPullDownButton` uses the same native `UIMenu` bridge for related
commands. It does not track a selected value or change its title after a command
runs.

```dart
LiquidGlassPullDownButton(
  title: 'More',
  width: 128,
  onSelected: (value) => handleCommand(value),
  actions: const <LiquidGlassAction>[
    LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
    LiquidGlassAction(
      title: 'Archive',
      value: 'archive',
      nativeSymbol: 'archivebox',
    ),
    LiquidGlassAction(
      title: 'Delete',
      value: 'delete',
      role: LiquidGlassActionRole.destructive,
      nativeSymbol: 'trash',
    ),
  ],
)
```

Leave `width` unset for full-width settings rows. Set it for compact toolbar,
form, or inline command cases.

For compact toolbar actions, keep the accessibility title and provide both a
Flutter icon and the matching native SF Symbol name.

```dart
LiquidGlassPullDownButton(
  title: 'Actions',
  icon: const Icon(Icons.more_horiz_rounded),
  nativeSymbol: 'ellipsis.circle',
  showTitle: false,
  onSelected: (value) => handleCommand(value),
  actions: const <LiquidGlassAction>[
    LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
    LiquidGlassAction(title: 'Archive', value: 'archive'),
  ],
)
```

Use pull-down commands to open richer Flutter content when the command needs
custom controls instead of a simple `UIAction`.

```dart
LiquidGlassPullDownButton(
  title: 'Adjust',
  width: 140,
  onSelected: (value) async {
    if (value == 'adjust') {
      await showLiquidGlassSheet<void>(
        context: context,
        title: const Text('Adjust intensity'),
        builder: (_) {
          return LiquidGlassSlider(
            value: intensity,
            nativePolicy: LiquidGlassNativePolicy.native,
            minimumNativeSymbol: 'sun.min',
            maximumNativeSymbol: 'sun.max',
            onChanged: (value) => setState(() => intensity = value),
          );
        },
      );
    }
  },
  actions: const <LiquidGlassAction>[
    LiquidGlassAction(title: 'Adjust intensity', value: 'adjust'),
    LiquidGlassAction(title: 'Reset', value: 'reset'),
  ],
)
```

### Sheets

Custom Flutter content uses a Flutter bottom sheet with the package glass
surface. The sheet automatically follows the keyboard and can use content,
medium, or large detents.

```dart
await showLiquidGlassSheet<void>(
  context: context,
  title: const Text('Add item'),
  detent: LiquidGlassSheetDetent.medium,
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
  builder: (context) {
    return const TextField(
      decoration: InputDecoration(labelText: 'Name'),
    );
  },
);
```

`showLiquidGlassSheet` uses the package's native-style scaffold defaults. You can
customize the fallback sheet's `margin`, `padding`, `handleMargin`, and
`headerSpacing` when a screen needs tighter or roomier content.

### Native iOS System Overlays

Simple system overlays call native UIKit on iOS and fall back to Flutter
elsewhere.

Native overlays complete with the selected value for user actions and `null`
for cancellation or dismissal. Native presentation failures surface as
`PlatformException`; the Flutter overlay wrappers catch those failures and show
the Flutter fallback only while the calling `BuildContext` is still mounted.

```dart
final action = await showLiquidGlassActionSheet(
  context: context,
  title: 'Choose action',
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
  actions: const <LiquidGlassAction>[
    LiquidGlassAction(
      title: 'Continue',
      value: 'continue',
      role: LiquidGlassActionRole.preferred,
    ),
    LiquidGlassAction(
      title: 'Delete',
      value: 'delete',
      role: LiquidGlassActionRole.destructive,
    ),
  ],
);
```

```dart
final result = await showLiquidGlassAlert(
  context: context,
  title: 'Confirm change',
  message: 'Choose one option.',
  insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
  actions: const <LiquidGlassAction>[
    LiquidGlassAction(
      title: 'Cancel',
      value: 'cancel',
      role: LiquidGlassActionRole.cancel,
    ),
    LiquidGlassAction(
      title: 'Apply',
      value: 'apply',
      role: LiquidGlassActionRole.preferred,
    ),
  ],
);
```

On iOS, alerts, action sheets, and option pickers default to native UIKit
presenters. The padding and spacing parameters customize only the Flutter
fallback shown on other platforms or after a native presentation failure; set
`useNativeOnIOS: false` when you need those custom fallback values on iOS.

```dart
final time = await showLiquidGlassTimePicker(
  context: context,
  initialTime: const TimeOfDay(hour: 8, minute: 30),
  title: 'Reminder time',
);
```

```dart
final option = await showLiquidGlassOptionPicker(
  context: context,
  title: 'Glass intensity',
  options: const <LiquidGlassAction>[
    LiquidGlassAction(title: 'Subtle', value: 'subtle'),
    LiquidGlassAction(title: 'Regular', value: 'regular'),
    LiquidGlassAction(title: 'Prominent', value: 'prominent'),
  ],
);
```

```dart
final date = await showLiquidGlassDatePicker(
  context: context,
  initialDate: DateTime.now(),
  minimumDate: DateTime(2020),
  maximumDate: DateTime(2030),
);
```

```dart
await showLiquidGlassShareSheet(
  context: context,
  items: const <String>['Shared from my app'],
);
```

## Customization

Use `LiquidGlassTheme` for app-wide defaults and pass
`LiquidGlassConfiguration` only where a component needs a local override.

```dart
LiquidGlassTheme(
  data: LiquidGlassThemeData.fromColorScheme(colorScheme).copyWith(
    surface: const LiquidGlassConfiguration(
      cornerRadius: 30,
      tintOpacity: 0.14,
      strokeOpacity: 0.22,
    ),
    appBarHeight: 66,
    tabBarHeight: 78,
  ),
  child: const App(),
)
```

Important knobs:

- `nativePolicy`: chooses automatic composition, forced Flutter, or explicit
  native iOS rendering.
- `role`: tells automatic policy whether a surface is content, chrome, floating,
  or modal.
- `preferNative`: a compatibility gate that can force surfaces back to Flutter.
- `cornerRadius`: controls continuous superellipse and native rounded shape.
- `cornerStyle`: uses all corners, top corners only, or no rounding.
- `tintColor` and `tintOpacity`: keep the component aligned with your app brand.
- `interactive`: marks tappable surfaces for native glass configuration; Flutter
  children still own gestures when a surface is used as a backdrop.
- `intensity`: chooses fallback material strength for older iOS.

## Architecture

For lifecycle rules, dependency direction, bridge contracts, and background
execution posture, see [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md).

The package is split by responsibility:

- `config`: theme and serializable glass configuration.
- `platform`: native policy resolution, method channels, and iOS platform-view
  identifiers.
- `surfaces`: the native-backed glass surface and Flutter fallback.
- `navigation`: app bar and tab bar composition.
- `controls`: button, menu, pull-down button, and Flutter-first controls with
  optional UIKit-backed slider, switch, segmented control, and stepper.
- `overlays`: sheets, dialogs, action sheets, option picker, date/time picker,
  and share sheet helpers.
- `scaffolds`: overlay-aware scaffold behavior.
- `ios`: Swift platform views, SwiftUI Liquid Glass, UIKit controls, and UIKit
  overlay presenters.

The public Dart API depends on small immutable configuration objects. Widgets do
not own app state, routing, localization, or dependency injection. This keeps the
package usable in Provider, Riverpod, Bloc, Cubit, vanilla Flutter, or any other
app architecture.

## Performance

Use native glass where it improves platform fidelity, but avoid overusing native
platform views. The automatic policy is intentionally conservative: content and
controls stay in Flutter unless a surface role or explicit native policy asks
for native rendering.

- Prefer native glass for a small number of stable surfaces: top bars, bottom
  bars, sheets, and floating controls.
- Avoid putting native glass surfaces in large scrolling lists.
- Avoid putting many native platform-view controls in long scrolling lists.
  Prefer explicit native controls only for focused forms, settings panels, and
  overlays.
- Keep `LiquidGlassConfiguration` stable; do not recreate highly customized
  platform-view surfaces every animation frame.
- For live sliders, update lightweight preview state in `onChanged` and persist
  expensive work in `onChangeEnd`.
- Keep slider `step` reasonable. Very small steps can produce excessive state
  updates if the host app performs heavy work during `onChanged`.
- Use Flutter fallback surfaces for repeated list rows, chips, and dense content.
- Keep blur behind readable content simple. Glass should clarify hierarchy, not
  become the dominant visual layer.
- Use `LiquidGlassScaffold` for bottom bars that should overlay content and hide
  above the keyboard.
- Test dark mode, RTL, text scaling, and reduced transparency/reduced motion in
  the host app.

## How The Native Bridge Works

Flutter owns the public API, state, routing, and fallbacks. iOS owns only the
UIKit/SwiftUI rendering or presentation that was explicitly requested.

1. A Flutter widget resolves `LiquidGlassNativePolicy` and decides whether to
   render a Flutter fallback or create an iOS platform view.
2. When a platform view is created, Flutter sends a typed map through
   `creationParams`. That map includes component state, colors, symbols,
   enabled state, native policy, and environment keys: `isDark`, `isRtl`, and
   `locale`.
3. The Swift platform view parses that map, applies semantic direction and
   accessibility language to the UIKit view, and configures the native control.
4. Native user actions call back through the per-view `MethodChannel`; Flutter
   updates app state and sends a new configuration back when needed.
5. `didChangeDependencies` and `didUpdateWidget` resync mounted native views, so
   theme, direction, and language changes rebuild native-side configuration
   without recreating the whole screen.
6. On `dispose`/`deinit`, both sides detach handlers so stale native views do
   not keep sending events into removed Flutter widgets.

This keeps the package close to the pattern used by apps that link Flutter UI to
native iOS workers: native surfaces and controls provide platform fidelity, but
Flutter remains the source of truth for app behavior.

## Rules For Adding Native Components

Every new native component should follow the existing bridge shape:

- Start with the Apple system primitive (`UIButton`, `UIMenu`, `UISlider`,
  `UITabBar`, `UIAlertController`, and so on) before creating custom native UI.
- Keep a Flutter fallback and keep the public Dart API platform-neutral.
- Add bridge keys in `liquid_glass_bridge_keys.dart` and use the shared
  environment configuration for `isDark`, `isRtl`, and `locale`.
- Sync configuration from `didChangeDependencies` when inherited Flutter values
  can affect native rendering or accessibility.
- Keep Swift parsing local and deterministic; use typed helper structs when the
  map has more than trivial fields.
- Send native events back to Flutter with method-channel callbacks instead of
  letting native code own routing or app state.
- Cover the component with Dart construction tests, channel resync tests,
  example showcase tests, and an iOS host build.
- Capture an example screenshot and document the real use case before exposing
  the component as package API.

## Platform Notes

Native Liquid Glass is only available when the app runs on iOS 26 or newer.
Older iOS versions use native UIKit material instead. Non-iOS platforms keep the
same API but render with Flutter so Android design remains under your app's
control.

The package follows the current Flutter plugin model and iOS availability gates:

- Flutter plugin packages:
  https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter platform views:
  https://docs.flutter.dev/platform-integration/ios/platform-views
- Apple Human Interface Guidelines:
  https://developer.apple.com/design/human-interface-guidelines/
- Apple Liquid Glass guidance:
  https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- UIKit `UIMenu`:
  https://developer.apple.com/documentation/uikit/uimenu
- UIKit `UIButton.showsMenuAsPrimaryAction`:
  https://developer.apple.com/documentation/uikit/uibutton/showsmenuasprimaryaction

[button-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-button.gif
[slider-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-slider.gif
[slider-endpoints-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-slider_endpoints.gif
[switch-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-switch.gif
[segmented-stepper-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-segmented_stepper.gif
[sheet-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-sheet.gif
[alert-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-alert.gif
[action-sheet-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-action_sheet.gif
[menu-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-menu.gif
[pull-down-gif]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/gifs/liquid-glass-pull_down.gif

[cupertino-liquid-glass-pkg]: https://pub.dev/packages/cupertino_liquid_glass
[oc-liquid-glass-pkg]: https://pub.dev/packages/oc_liquid_glass
[liquid-glass-flutter-pkg]: https://pub.dev/packages/liquid_glass_flutter
[flutter-liquid-glass-pkg]: https://pub.dev/packages/flutter_liquid_glass
[glass-pkg]: https://pub.dev/packages/glass

[environment-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-environment.png
[rtl-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-rtl-language.png
[surface-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-surface.png
[app-bar-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-app-bar.png
[tab-bar-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-tab-bar.png
[action-menu-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-action-menu-button.png
[grouped-menu-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-grouped-command-menu.png
[pull-down-slider-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-pull-down-slider.png
[option-picker-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-option-picker.png
[date-picker-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-date-picker.png
[time-picker-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-time-picker.png
[share-sheet-img]: https://raw.githubusercontent.com/YaserH25/native_liquid_glass_flutter/main/doc/screenshots/components/liquid-glass-share-sheet.png
