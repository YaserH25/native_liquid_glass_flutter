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

Native code must not own app domain state or routing. Native tab bar taps and
native app bar back actions are bridged back to Flutter callbacks, and the host
Flutter app remains responsible for changing routes and selected indexes.

## Native Policy

`LiquidGlassNativePolicy.automatic` keeps content and controls in Flutter,
while allowing chrome, floating surfaces, and modals to use native iOS
rendering. Explicit `native` policy is required for native iOS controls.

Native app bar and tab bar chrome can use UIKit layout on iOS, but Flutter still
owns the public widget API, routing callbacks, fallback composition, and selected
state.

## Bridge Contracts

All `MethodChannel` method names and map keys are part of the public bridge
contract. Every new key or method must be covered by:
- Dart platform contract test
- Swift parser/unit test where parsing is non-trivial
- iOS host build

Every native platform-view configuration that depends on inherited Flutter
state must include the shared environment fields:
- `isDark`
- `isRtl`
- `locale`

Swift views must apply those fields to `overrideUserInterfaceStyle`,
`semanticContentAttribute`, and `accessibilityLanguage` where UIKit exposes the
property. This keeps mounted native views aligned with app theme, text
direction, language, and VoiceOver pronunciation when Flutter rebuilds inherited
state.

## Native Component Addition Rule

Every new native component must follow the package bridge pattern:

1. Start from the Apple system control or presentation primitive. If an existing
   platform view can express the behavior with an explicit bridge flag, reuse it
   instead of registering another view type.
2. Keep Flutter as the owner of the public API, state, fallback UI, and routing.
   Native code owns only rendering, gesture delivery, and platform presentation.
3. Add typed Dart configuration fields, bridge keys, and native parsing together.
   Avoid ad hoc string keys outside the bridge layer unless the Swift side already
   uses the established map parser for that component.
4. Install per-view method handlers with weak native captures, detach Dart
   handlers in `dispose`, and clear Swift handlers in `deinit`.
5. Sync configuration in `didChangeDependencies` and `didUpdateWidget` whenever
   inherited theme, locale, direction, enabled state, or selected value can
   affect native rendering.
6. Provide a Flutter fallback for non-iOS and for explicit Flutter policy.
7. Add tests before implementation: widget/platform-view construction,
   callback routing, inherited-state resync where applicable, example showcase
   coverage, and iOS host tests for Swift behavior when native parsing changes.
8. Add the component to the example showcase with plain visible state, so manual
   simulator validation can confirm the native interaction and Flutter callback.

## Lifecycle Rules

Every Swift platform view that installs a method handler must clear it in
`deinit`. Every Dart native wrapper must clear handlers in `dispose`.

Native wrappers whose configuration depends on inherited Flutter state must
sync in `didChangeDependencies` and `didUpdateWidget`.

## Overlay Results And Cancellation

Native overlays complete with:
- selected value for user action
- `null` for user cancellation or dismissal
- `PlatformException` for native presentation failure

Flutter overlay wrappers must catch `PlatformException` and use fallback UI when
the calling `BuildContext` is still mounted.

`cancelPresentedOverlay` is a best-effort native cancellation hook. It returns
`true` when an active native overlay was dismissed, `false` when no supported
native overlay was active, and `null` on non-iOS platforms where native overlay
cancellation is not available.

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
- iOS host `xcodebuild build-for-testing` on the current simulator
- simulator smoke test for native controls and overlays
- leak/performance pass for repeated platform-view creation/disposal

## Manual Simulator Smoke Checklist

- Native slider drags with cursor/finger and emits live values.
- Native slider endpoint symbols render and non-continuous mode reports on
  release.
- Native switch toggles once per tap.
- Native segmented control changes once per segment tap.
- Native stepper clamps min/max.
- Native tab bar uses OS icon/label spacing and stays bottom-pinned.
- Native tab bar badges and disabled items match `UITabBarItem` behavior.
- Native menu opens as a `UIMenu` and updates Flutter state.
- Native menu action icons, disabled state, groups, and destructive roles match
  the typed Dart action metadata.
- Native app bar trailing actions and action menus call back to Flutter without
  owning navigation state.
- Pull-down button opens command actions without changing its title.
- Icon action menu opens command actions from a compact button.
- Alert/action sheet/date/time/share overlays return expected values.
- Theme switch updates mounted native controls.
- RTL flips directional chrome.
- Dynamic Type does not clip tab/menu/app-bar labels.
- Keyboard hides bottom chrome when configured.
- App background/foreground does not leave dangling overlays.
