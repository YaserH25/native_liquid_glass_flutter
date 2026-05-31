import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  testWidgets('button renders child and handles taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LiquidGlassTheme(
          data: LiquidGlassThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: Scaffold(
            body: LiquidGlassButton(
              onPressed: () => tapped = true,
              child: const Text('Press'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Press'));

    expect(tapped, true);
  });

  testWidgets('tab bar exposes selected tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassTabBar(
            selectedIndex: 1,
            onSelected: (_) {},
            items: const <LiquidGlassTabItem>[
              LiquidGlassTabItem(icon: Icon(Icons.home), label: Text('Home')),
              LiquidGlassTabItem(icon: Icon(Icons.book), label: Text('Books')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Books'), findsOneWidget);
  });

  testWidgets('slider uses Flutter fallback and reports live value', (
    tester,
  ) async {
    var value = 0.4;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassSlider(
            value: value,
            onChanged: (nextValue) => value = nextValue,
          ),
        ),
      ),
    );

    expect(find.byType(Slider), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(120, 0));

    expect(value, isNot(0.4));
  });

  testWidgets('slider handles a step larger than its range', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassSlider(
            value: 0.5,
            min: 0,
            max: 1,
            step: 5,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('switch fallback reports changes', (tester) async {
    var value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassSwitch(
            value: value,
            onChanged: (nextValue) => value = nextValue,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));

    expect(value, true);
  });

  testWidgets('segmented control fallback reports selection', (tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassSegmentedControl(
            selectedIndex: selectedIndex,
            onChanged: (index) => selectedIndex = index,
            segments: const <LiquidGlassSegment>[
              LiquidGlassSegment(label: 'One'),
              LiquidGlassSegment(label: 'Two'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Two'));

    expect(selectedIndex, 1);
  });

  testWidgets('stepper fallback clamps value', (tester) async {
    var value = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassStepper(
            value: value,
            min: 0,
            max: 2,
            onChanged: (nextValue) => value = nextValue,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));

    expect(value, 2);
  });
}
