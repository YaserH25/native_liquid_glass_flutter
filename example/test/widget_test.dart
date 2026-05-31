import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';
import 'package:native_liquid_glass_flutter_example/example_app.dart';
import 'package:native_liquid_glass_flutter_example/widgets/configuration_showcase.dart';
import 'package:native_liquid_glass_flutter_example/widgets/example_section.dart';
import 'package:native_liquid_glass_flutter_example/widgets/navigation_showcase.dart';
import 'package:native_liquid_glass_flutter_example/widgets/native_controls_showcase.dart';
import 'package:native_liquid_glass_flutter_example/widgets/overlay_showcase.dart';

void main() {
  testWidgets('example renders package controls', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Native slider'), findsOneWidget);
    expect(find.text('Slider endpoints'), findsOneWidget);
    expect(find.text('Open slider sheet'), findsOneWidget);
    expect(find.text('Controls'), findsWidgets);
  });

  testWidgets('example uses UIKit controls on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NativeControlsShowcase())),
      );

      expect(find.byType(UiKitView), findsWidgets);
      expect(find.text('Native slider'), findsOneWidget);
      expect(find.text('Slider endpoints'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Native switch'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Native switch'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Native segmented control'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Native segmented control'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Native stepper'), findsOneWidget);
      expect(find.byType(UiKitView), findsWidgets);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('overlay showcase includes each overlay action', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.text('Overlays'));
    await tester.pumpAndSettle();

    for (final title in <String>[
      'Sheet scaffold',
      'Popup alert',
      'Action sheet',
      'Native UIMenu',
      'Pull-down button',
      'Action menu button',
      'Grouped command menu',
      'Pull-down slider',
      'Option picker',
      'Date picker',
      'Time picker',
      'Share sheet',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }

    await tester.scrollUntilVisible(
      find.text('Native UIMenu'),
      -180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Selected: Comfortable'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pull-down button'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Last command: None'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Action menu button'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Last icon action: None'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Grouped command menu'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Last grouped action: None'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pull-down slider'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Intensity: 56%'), findsOneWidget);
  });

  testWidgets('example sections do not force compact controls full width', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ExampleSection(
                title: 'Compact case',
                children: <Widget>[
                  SizedBox(key: Key('compact-control'), width: 64, height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('compact-control'))).width, 64);
  });

  testWidgets('configuration showcase includes navigation components', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ConfigurationShowcase())),
    );

    for (final title in <String>[
      'Native app bar',
      'Native tab bar',
      'LiquidGlassScaffold',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('navigation showcase uses native app and tab bars on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConfigurationShowcase())),
      );

      await tester.scrollUntilVisible(
        find.text('Native tab bar'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        contains(LiquidGlassPlatform.navigationBarViewType),
      );
      expect(
        views.map((view) => view.viewType),
        contains(LiquidGlassPlatform.tabBarViewType),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('navigation showcase can switch native app bar to RTL on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: NavigationShowcase()),
          ),
        ),
      );

      await tester.tap(find.text('RTL'));
      await tester.pumpAndSettle();

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      final navigationBar = views.firstWhere(
        (view) => view.viewType == LiquidGlassPlatform.navigationBarViewType,
      );
      final params = navigationBar.creationParams as Map<Object?, Object?>;
      expect(params['isRtl'], isTrue);
      expect(find.text('Direction: RTL'), findsOneWidget);
      expect(find.text('Last app bar action: None'), findsOneWidget);
      expect(find.text('Saved badge: 2'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('navigation showcase opens a native app bar detail route', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: NavigationShowcase()),
          ),
        ),
      );

      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail screen'), findsOneWidget);
      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        contains(LiquidGlassPlatform.navigationBarViewType),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('overlay UIMenu showcase uses UIKit on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OverlayShowcase())),
      );

      await tester.scrollUntilVisible(
        find.text('Native UIMenu'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Native UIMenu'), findsOneWidget);
      expect(find.text('Selected: Comfortable'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pull-down button'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pull-down button'), findsOneWidget);
      expect(find.text('Last command: None'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Action menu button'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Action menu button'), findsOneWidget);
      expect(find.text('Last icon action: None'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Grouped command menu'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Last grouped action: None'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pull-down slider'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pull-down slider'), findsOneWidget);
      expect(find.text('Intensity: 56%'), findsOneWidget);
      expect(find.byType(UiKitView), findsWidgets);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
