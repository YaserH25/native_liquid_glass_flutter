import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter_example/example_app.dart';
import 'package:native_liquid_glass_flutter_example/widgets/native_controls_showcase.dart';

void main() {
  testWidgets('example renders package controls', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Native slider'), findsOneWidget);
    expect(find.text('Open slider sheet'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
  });

  testWidgets('example uses UIKit controls on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NativeControlsShowcase())),
      );

      expect(find.byType(UiKitView), findsWidgets);
      expect(find.text('Native slider'), findsOneWidget);
      expect(find.text('Native switch'), findsOneWidget);
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
      'Bottom sheet',
      'Popup alert',
      'Action sheet',
      'Native menu',
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
  });
}
