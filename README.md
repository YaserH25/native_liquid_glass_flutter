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

## Installation

```yaml
dependencies:
  native_liquid_glass_flutter: ^0.0.1
```

For local development before publishing:

```yaml
dependencies:
  native_liquid_glass_flutter:
    path: ../native_liquid_glass_flutter
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

## Component Showcase

Screenshots below were captured from the current iPhone 17 Pro Simulator.

### Environment, Surface, And RTL

`Directionality`, `Localizations.localeOf`, and `Theme` changes are part of the
native bridge configuration. Mounted platform views resync when any of those
inherited values changes, so developers can validate LTR/RTL and language
changes directly in the example app.

![Environment showcase](doc/screenshots/components/liquid-glass-environment.png)
![RTL and Arabic language showcase](doc/screenshots/components/liquid-glass-rtl-language.png)
![Glass surface showcase](doc/screenshots/components/liquid-glass-surface.png)

### Navigation

Use the native app bar and tab bar when the OS should own navigation chrome
layout, safe-area sizing, item spacing, labels, symbols, badges, and disabled
states while Flutter keeps routing and selected state.

![Native app bar showcase](doc/screenshots/components/liquid-glass-app-bar.png)
![Native tab bar showcase](doc/screenshots/components/liquid-glass-tab-bar.png)

### Controls

Core controls are Flutter-first by default and can opt into UIKit on iOS with
`nativePolicy: LiquidGlassNativePolicy.native`.

![LiquidGlassButton showcase](doc/screenshots/components/liquid-glass-button.png)
![LiquidGlassSlider showcase](doc/screenshots/components/liquid-glass-slider.png)
![LiquidGlassSlider endpoint symbols](doc/screenshots/components/liquid-glass-slider-endpoints.png)
![LiquidGlassSwitch showcase](doc/screenshots/components/liquid-glass-switch.png)
![LiquidGlassSegmentedControl showcase](doc/screenshots/components/liquid-glass-segmented-control.png)
![LiquidGlassStepper showcase](doc/screenshots/components/liquid-glass-stepper.png)

### Menus And Pull-Down Buttons

Menus are backed by UIKit `UIButton`, `UIMenu`, and `UIAction`. Selection menus
show the current value and let UIKit draw the checkmark. Command menus keep the
button label stable and return the selected command to Flutter.

![Native UIMenu closed](doc/screenshots/components/liquid-glass-uimenu.png)
![Native UIMenu open](doc/screenshots/components/liquid-glass-uimenu-open.png)
![Pull-down button showcase](doc/screenshots/components/liquid-glass-pull-down-button.png)
![Icon action menu showcase](doc/screenshots/components/liquid-glass-action-menu-button.png)
![Grouped command menu showcase](doc/screenshots/components/liquid-glass-grouped-command-menu.png)
![Pull-down slider command](doc/screenshots/components/liquid-glass-pull-down-slider.png)

### Overlays And Pickers

Overlays use native UIKit presenters on iOS and Flutter fallbacks elsewhere.

![Bottom sheet showcase](doc/screenshots/components/liquid-glass-bottom-sheet.png)
![Alert showcase](doc/screenshots/components/liquid-glass-alert.png)
![Action sheet showcase](doc/screenshots/components/liquid-glass-action-sheet.png)
![Option picker showcase](doc/screenshots/components/liquid-glass-option-picker.png)
![Date picker showcase](doc/screenshots/components/liquid-glass-date-picker.png)
![Time picker showcase](doc/screenshots/components/liquid-glass-time-picker.png)
![Share sheet showcase](doc/screenshots/components/liquid-glass-share-sheet.png)

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
  builder: (context) {
    return const TextField(
      decoration: InputDecoration(labelText: 'Name'),
    );
  },
);
```

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
- Dart package publishing and package layout:
  https://dart.dev/tools/pub/publishing
- Apple Human Interface Guidelines:
  https://developer.apple.com/design/human-interface-guidelines/
- Apple Liquid Glass guidance:
  https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- UIKit `UIMenu`:
  https://developer.apple.com/documentation/uikit/uimenu
- UIKit `UIButton.showsMenuAsPrimaryAction`:
  https://developer.apple.com/documentation/uikit/uibutton/showsmenuasprimaryaction

## Publishing Checklist

Before publishing:

```sh
flutter pub get
dart format lib test example/lib example/test example/integration_test
flutter analyze
flutter test
cd example
flutter test
flutter build ios --simulator
cd ..
flutter pub publish --dry-run
```

Then update:

- `pubspec.yaml` homepage, repository, issue tracker, documentation, and topics.
- `ios/native_liquid_glass_flutter.podspec` author, homepage, summary, and
  Swift version.
- `CHANGELOG.md` with the release notes.
- `LICENSE` with the intended package license.
- `.pubignore` so internal planning files and generated output are not shipped.
