import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';
import 'package:native_liquid_glass_flutter/src/platform/liquid_glass_native_view_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'native_liquid_glass_flutter/test_lifecycle/7';
  final methodChannel = MethodChannel(channelName);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test(
    'native view channel attaches, deduplicates sync, and detaches',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (call) async {
            calls.add(call);
            return null;
          });

      final channel = LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            'native_liquid_glass_flutter/test_lifecycle/$viewId',
      );

      expect(channel.isAttached, false);

      await channel.sync(<String, Object?>{'value': 0});
      expect(calls, isEmpty);

      channel.attach(7, handler: (_) async {});
      expect(channel.isAttached, true);

      await channel.sync(<String, Object?>{'value': 1});
      await channel.sync(<String, Object?>{'value': 1});
      await channel.sync(<String, Object?>{'value': 1}, force: true);
      await channel.sync(<String, Object?>{'value': 2}, signature: 'same');
      await channel.sync(<String, Object?>{'value': 3}, signature: 'same');
      await channel.invoke('setSelectedIndex', <String, Object>{'index': 2});

      expect(calls.map((call) => call.method), <String>[
        'setConfiguration',
        'setConfiguration',
        'setConfiguration',
        'setSelectedIndex',
      ]);
      expect(calls[0].arguments, <String, Object?>{'value': 1});
      expect(calls[1].arguments, <String, Object?>{'value': 1});
      expect(calls[2].arguments, <String, Object?>{'value': 2});
      expect(calls[3].arguments, <String, Object>{'index': 2});

      channel.detach();
      expect(channel.isAttached, false);

      await channel.sync(<String, Object?>{'value': 4}, force: true);
      await channel.invoke('setSelectedIndex', <String, Object>{'index': 3});

      expect(calls.length, 4);
    },
  );

  testWidgets('native slider resyncs after inherited theme changes', (
    tester,
  ) async {
    const sliderChannel = MethodChannel('native_liquid_glass_flutter/slider_1');
    final calls = <MethodCall>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sliderChannel, (call) async {
          calls.add(call);
          return null;
        });

    try {
      await tester.pumpWidget(_nativeSliderApp(Colors.teal));

      final state = tester.state<LiquidGlassSliderState>(
        find.byType(LiquidGlassSlider),
      );
      state.configureChannel(1);
      await tester.pump();

      await tester.pumpWidget(_nativeSliderApp(Colors.deepOrange));
      await tester.pump();

      final configurationCalls = calls
          .where((call) => call.method == 'setConfiguration')
          .toList();
      expect(configurationCalls.length, greaterThanOrEqualTo(2));
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(sliderChannel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native app bar handles back callback while mounted', (
    tester,
  ) async {
    var backCalls = 0;

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        _themedApp(
          Colors.teal,
          LiquidGlassNativeAppBar(
            title: 'Native',
            canGoBack: true,
            onBack: () => backCalls += 1,
          ),
        ),
      );

      final state = tester.state<LiquidGlassNativeAppBarState>(
        find.byType(LiquidGlassNativeAppBar),
      );

      await state.handleMethodCall(const MethodCall('onBack'));
      await state.handleMethodCall(const MethodCall('ignored'));

      expect(backCalls, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native app bar syncs configuration after channel attach', (
    tester,
  ) async {
    const navigationChannel = MethodChannel(
      'native_liquid_glass_flutter/navigation_bar/1',
    );
    final calls = <MethodCall>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(navigationChannel, (call) async {
          calls.add(call);
          return null;
        });

    try {
      await tester.pumpWidget(
        _nativeAppBarApp(title: 'Native', seedColor: Colors.teal),
      );

      final state = tester.state<LiquidGlassNativeAppBarState>(
        find.byType(LiquidGlassNativeAppBar),
      );
      state.configureChannel(1);
      await tester.pump();

      await tester.pumpWidget(
        _nativeAppBarApp(title: 'Updated', seedColor: Colors.deepOrange),
      );
      await tester.pump();

      final configurationCalls = calls
          .where((call) => call.method == 'setConfiguration')
          .toList();
      expect(configurationCalls.length, greaterThanOrEqualTo(2));
      expect(
        configurationCalls.first.arguments,
        containsPair('title', 'Native'),
      );
      expect(
        configurationCalls.first.arguments,
        containsPair('canGoBack', true),
      );
      expect(
        configurationCalls.last.arguments,
        containsPair('title', 'Updated'),
      );
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(navigationChannel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native app bar height matches preferred height', (tester) async {
    const appBar = LiquidGlassNativeAppBar(title: 'Native', canGoBack: false);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: LiquidGlassTheme(
            data: LiquidGlassThemeData.fromColorScheme(
              ColorScheme.fromSeed(seedColor: Colors.teal),
            ).copyWith(appBarHeight: 72),
            child: const Scaffold(appBar: appBar, body: SizedBox.shrink()),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(UiKitView),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(appBar.preferredSize.height, 64);
      expect(sizedBox.height, appBar.preferredSize.height);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native switch resyncs after inherited theme changes', (
    tester,
  ) async {
    const switchChannel = MethodChannel('native_liquid_glass_flutter/switch_1');
    final calls = <MethodCall>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(switchChannel, (call) async {
          calls.add(call);
          return null;
        });

    try {
      await tester.pumpWidget(_nativeSwitchApp(Colors.teal));

      final state = tester.state<LiquidGlassSwitchState>(
        find.byType(LiquidGlassSwitch),
      );
      state.configureChannel(1);
      await tester.pump();

      await tester.pumpWidget(_nativeSwitchApp(Colors.deepOrange));
      await tester.pump();

      expect(_configurationCallCount(calls), greaterThanOrEqualTo(2));
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(switchChannel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'native segmented control resyncs after inherited theme changes',
    (tester) async {
      const segmentedChannel = MethodChannel(
        'native_liquid_glass_flutter/segmented_1',
      );
      final calls = <MethodCall>[];

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(segmentedChannel, (call) async {
            calls.add(call);
            return null;
          });

      try {
        await tester.pumpWidget(_nativeSegmentedControlApp(Colors.teal));

        final state = tester.state<LiquidGlassSegmentedControlState>(
          find.byType(LiquidGlassSegmentedControl),
        );
        state.configureChannel(1);
        await tester.pump();

        await tester.pumpWidget(_nativeSegmentedControlApp(Colors.deepOrange));
        await tester.pump();

        expect(_configurationCallCount(calls), greaterThanOrEqualTo(2));
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(segmentedChannel, null);
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('native stepper resyncs after inherited theme changes', (
    tester,
  ) async {
    const stepperChannel = MethodChannel(
      'native_liquid_glass_flutter/stepper_1',
    );
    final calls = <MethodCall>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(stepperChannel, (call) async {
          calls.add(call);
          return null;
        });

    try {
      await tester.pumpWidget(_nativeStepperApp(Colors.teal));

      final state = tester.state<LiquidGlassStepperState>(
        find.byType(LiquidGlassStepper),
      );
      state.configureChannel(1);
      await tester.pump();

      await tester.pumpWidget(_nativeStepperApp(Colors.deepOrange));
      await tester.pump();

      expect(_configurationCallCount(calls), greaterThanOrEqualTo(2));
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(stepperChannel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native menu button resyncs when inherited theme changes', (
    tester,
  ) async {
    const menuChannel = MethodChannel(
      'native_liquid_glass_flutter/menu_button/1',
    );
    final calls = <MethodCall>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(menuChannel, (call) async {
          calls.add(call);
          return null;
        });

    try {
      await tester.pumpWidget(_nativeMenuButtonApp(Colors.teal));

      final state = tester.state<LiquidGlassMenuButtonState>(
        find.byType(LiquidGlassMenuButton),
      );
      state.configureChannel(1);
      await tester.pump();
      final initialConfiguration =
          calls.last.arguments as Map<Object?, Object?>;
      calls.clear();

      await tester.pumpWidget(_nativeMenuButtonApp(Colors.deepOrange));
      await tester.pump();

      final configurationCalls = calls
          .where((call) => call.method == 'setConfiguration')
          .toList();
      expect(configurationCalls, isNotEmpty);

      final updatedConfiguration =
          configurationCalls.last.arguments as Map<Object?, Object?>;
      expect(
        updatedConfiguration['tintColor'],
        isNot(initialConfiguration['tintColor']),
      );
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(menuChannel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native components resync after direction and locale changes', (
    tester,
  ) async {
    final channels = <MethodChannel, List<MethodCall>>{
      const MethodChannel('native_liquid_glass_flutter/surface_1'):
          <MethodCall>[],
      const MethodChannel('native_liquid_glass_flutter/slider_1'):
          <MethodCall>[],
      const MethodChannel('native_liquid_glass_flutter/switch_1'):
          <MethodCall>[],
      const MethodChannel('native_liquid_glass_flutter/segmented_1'):
          <MethodCall>[],
      const MethodChannel('native_liquid_glass_flutter/stepper_1'):
          <MethodCall>[],
      const MethodChannel('native_liquid_glass_flutter/menu_button/1'):
          <MethodCall>[],
    };

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    for (final entry in channels.entries) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(entry.key, (call) async {
            entry.value.add(call);
            return null;
          });
    }

    try {
      await tester.pumpWidget(
        _nativeComponentsApp(
          seedColor: Colors.teal,
          locale: const Locale('en'),
          textDirection: TextDirection.ltr,
        ),
      );

      tester
          .state<LiquidGlassSurfaceBackdropState>(
            find.byType(LiquidGlassSurfaceBackdrop),
          )
          .configureChannel(1);
      tester
          .state<LiquidGlassSliderState>(find.byType(LiquidGlassSlider))
          .configureChannel(1);
      tester
          .state<LiquidGlassSwitchState>(find.byType(LiquidGlassSwitch))
          .configureChannel(1);
      tester
          .state<LiquidGlassSegmentedControlState>(
            find.byType(LiquidGlassSegmentedControl),
          )
          .configureChannel(1);
      tester
          .state<LiquidGlassStepperState>(find.byType(LiquidGlassStepper))
          .configureChannel(1);
      tester
          .state<LiquidGlassMenuButtonState>(find.byType(LiquidGlassMenuButton))
          .configureChannel(1);
      await tester.pump();

      for (final calls in channels.values) {
        calls.clear();
      }

      await tester.pumpWidget(
        _nativeComponentsApp(
          seedColor: Colors.teal,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pump();

      for (final entry in channels.entries) {
        final configurationCalls = entry.value
            .where((call) => call.method == 'setConfiguration')
            .toList();
        expect(configurationCalls, isNotEmpty, reason: entry.key.name);
        final configuration =
            configurationCalls.last.arguments as Map<Object?, Object?>;
        expect(configuration['isRtl'], isTrue, reason: entry.key.name);
        expect(configuration['locale'], 'ar', reason: entry.key.name);
      }
    } finally {
      for (final channel in channels.keys) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      }
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget _nativeSliderApp(Color seedColor) {
  return _themedApp(
    seedColor,
    LiquidGlassSlider(
      value: 0.5,
      nativePolicy: LiquidGlassNativePolicy.native,
      onChanged: (_) {},
    ),
  );
}

Widget _nativeAppBarApp({required String title, required Color seedColor}) {
  return MaterialApp(
    home: LiquidGlassTheme(
      data: LiquidGlassThemeData.fromColorScheme(
        ColorScheme.fromSeed(seedColor: seedColor),
      ),
      child: Scaffold(
        appBar: LiquidGlassNativeAppBar(
          title: title,
          canGoBack: true,
          onBack: () {},
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );
}

Widget _nativeSwitchApp(Color seedColor) {
  return _themedApp(
    seedColor,
    LiquidGlassSwitch(
      value: true,
      nativePolicy: LiquidGlassNativePolicy.native,
      onChanged: (_) {},
    ),
  );
}

Widget _nativeSegmentedControlApp(Color seedColor) {
  return _themedApp(
    seedColor,
    LiquidGlassSegmentedControl(
      selectedIndex: 0,
      nativePolicy: LiquidGlassNativePolicy.native,
      onChanged: (_) {},
      segments: const <LiquidGlassSegment>[
        LiquidGlassSegment(label: 'One'),
        LiquidGlassSegment(label: 'Two'),
      ],
    ),
  );
}

Widget _nativeStepperApp(Color seedColor) {
  return _themedApp(
    seedColor,
    LiquidGlassStepper(
      value: 4,
      nativePolicy: LiquidGlassNativePolicy.native,
      onChanged: (_) {},
    ),
  );
}

Widget _nativeMenuButtonApp(Color seedColor) {
  return _themedApp(
    seedColor,
    LiquidGlassMenuButton(
      title: 'Density',
      value: 'compact',
      options: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'Compact', value: 'compact'),
        LiquidGlassAction(title: 'Comfortable', value: 'comfortable'),
      ],
      onChanged: (_) {},
    ),
  );
}

Widget _nativeComponentsApp({
  required Color seedColor,
  required Locale locale,
  required TextDirection textDirection,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: Directionality(
            textDirection: textDirection,
            child: LiquidGlassTheme(
              data: LiquidGlassThemeData.fromColorScheme(
                ColorScheme.fromSeed(seedColor: seedColor),
              ),
              child: Scaffold(
                body: Column(
                  children: <Widget>[
                    const LiquidGlassSurface(
                      configuration: LiquidGlassConfiguration(
                        nativePolicy: LiquidGlassNativePolicy.native,
                      ),
                      child: Text('surface'),
                    ),
                    LiquidGlassSlider(
                      value: 0.5,
                      nativePolicy: LiquidGlassNativePolicy.native,
                      onChanged: (_) {},
                    ),
                    LiquidGlassSwitch(
                      value: true,
                      nativePolicy: LiquidGlassNativePolicy.native,
                      onChanged: (_) {},
                    ),
                    LiquidGlassSegmentedControl(
                      selectedIndex: 0,
                      nativePolicy: LiquidGlassNativePolicy.native,
                      onChanged: (_) {},
                      segments: const <LiquidGlassSegment>[
                        LiquidGlassSegment(label: 'One'),
                        LiquidGlassSegment(label: 'Two'),
                      ],
                    ),
                    LiquidGlassStepper(
                      value: 4,
                      nativePolicy: LiquidGlassNativePolicy.native,
                      onChanged: (_) {},
                    ),
                    LiquidGlassMenuButton(
                      title: 'Density',
                      value: 'compact',
                      options: const <LiquidGlassAction>[
                        LiquidGlassAction(title: 'Compact', value: 'compact'),
                        LiquidGlassAction(
                          title: 'Comfortable',
                          value: 'comfortable',
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _themedApp(Color seedColor, Widget child) {
  return MaterialApp(
    home: LiquidGlassTheme(
      data: LiquidGlassThemeData.fromColorScheme(
        ColorScheme.fromSeed(seedColor: seedColor),
      ),
      child: Scaffold(body: child),
    ),
  );
}

int _configurationCallCount(List<MethodCall> calls) {
  return calls.where((call) => call.method == 'setConfiguration').length;
}
