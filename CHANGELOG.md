## 0.0.8

* Added an animated `LiquidGlassTabBar` GIF that shows tab selection changes and
  horizontal dragging across the native tab bar.
* Added the tab bar GIF to the README and pub.dev screenshot metadata.

## 0.0.7

* Removed the remaining static screenshot references from the README and package
  screenshot metadata.
* Switched pub.dev package screenshots to the animated GIF set only.

## 0.0.6

* Reworked the README media gallery to use GIFs for interactive components and
  keep static screenshots only for layout, navigation, pickers, and menu
  variants.
* Removed duplicate static screenshots that were replaced by animated GIFs.

## 0.0.5

* Added simulator-recorded animated GIFs for native controls, menus, and
  overlays.
* Added a reusable Dart/Maestro GIF recording tool for the example gallery.
* Expanded the README with a comparison against visual-only Flutter glass
  packages.

## 0.0.4

* Restored absolute raw GitHub screenshot URLs now that the repository is public,
  so images render inside the pub.dev README.

## 0.0.3

* Switched README screenshot links to package-relative paths so pub.dev can
  serve the images from the published package archive.

## 0.0.2

* Updated the public README for pub.dev with absolute screenshot links for each
  component showcase.
* Added pub.dev screenshot metadata.
* Removed internal setup and publishing-only content from the package README.

## 0.0.1

* Initial plugin package with native iOS Liquid Glass surfaces and adaptive
  Flutter fallbacks for non-iOS platforms.
* Added glass app bar, native app bar bridge, native tab bar bridge, scaffold,
  button, sheets, dialogs, action sheet, option picker, date/time pickers, and
  share sheet helpers.
* Added native iOS slider, switch, segmented control, stepper, `UIMenu`, and
  pull-down button helpers with Flutter fallbacks.
* Added bridge support for theme, text direction, and locale updates so mounted
  native views resync when the Flutter app changes language or direction.
* Added example component gallery screenshots and package architecture docs.
