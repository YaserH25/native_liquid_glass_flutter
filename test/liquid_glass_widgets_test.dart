import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  testWidgets(
    'content surfaces use Flutter material in automatic mode on iOS',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LiquidGlassSurface(child: Text('content'))),
          ),
        );

        expect(find.byType(UiKitView), findsNothing);
        expect(find.text('content'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'content surfaces can explicitly opt into native material on iOS',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LiquidGlassSurface(
                configuration: LiquidGlassConfiguration(
                  nativePolicy: LiquidGlassNativePolicy.native,
                ),
                child: Text('native content'),
              ),
            ),
          ),
        );

        expect(find.byType(UiKitView), findsOneWidget);
        expect(find.text('native content'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('app bar keeps chrome role with custom configuration on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: LiquidGlassAppBar(
              title: Text('Title'),
              configuration: LiquidGlassConfiguration(cornerRadius: 22),
            ),
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(UiKitView), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('simple app bar uses native navigation bar on iOS', (
    tester,
  ) async {
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

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        contains(LiquidGlassPlatform.navigationBarViewType),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('app bar fallback height matches preferred height', (
    tester,
  ) async {
    const appBar = LiquidGlassAppBar(center: Text('Brand'));

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
            of: find.byType(LiquidGlassSurface),
            matching: find.byType(SizedBox),
          )
          .first,
    );

    expect(appBar.preferredSize.height, 64);
    expect(sizedBox.height, appBar.preferredSize.height);
  });

  testWidgets('custom app bar slots keep Flutter fallback on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LiquidGlassAppBar(
              title: const Text('Fallback'),
              center: const Icon(Icons.auto_awesome_rounded),
              leading: const Icon(Icons.menu_rounded),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        isNot(contains(LiquidGlassPlatform.navigationBarViewType)),
      );
      expect(find.text('Fallback'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tab bar keeps chrome role with custom configuration on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassTabBar(
              selectedIndex: 0,
              configuration: const LiquidGlassConfiguration(cornerRadius: 22),
              onSelected: (_) {},
              items: const <LiquidGlassTabItem>[
                LiquidGlassTabItem(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  nativeSymbol: 'house',
                ),
                LiquidGlassTabItem(
                  icon: Icon(Icons.book),
                  label: Text('Books'),
                  nativeSymbol: 'book',
                ),
              ],
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.viewType, LiquidGlassPlatform.tabBarViewType);
      expect(view.gestureRecognizers, isNotNull);
      expect(view.gestureRecognizers, isNotEmpty);

      final recognizer = view.gestureRecognizers!.first.constructor();
      addTearDown(recognizer.dispose);
      expect(recognizer, isA<TapGestureRecognizer>());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native tab bar owns safe-area height on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: Scaffold(
              body: LiquidGlassTabBar(
                selectedIndex: 0,
                onSelected: (_) {},
                items: const <LiquidGlassTabItem>[
                  LiquidGlassTabItem(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                    nativeSymbol: 'house',
                  ),
                  LiquidGlassTabItem(
                    icon: Icon(Icons.book),
                    label: Text('Books'),
                    nativeSymbol: 'book',
                  ),
                ],
              ),
            ),
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
      expect(sizedBox.height, LiquidGlassTabBar.nativeContentHeight + 34);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('scaffold exposes bottom scroll padding for overlaid tab bar', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    double? capturedPadding;

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: LiquidGlassScaffold(
              bottomNavigationBar: LiquidGlassTabBar(
                selectedIndex: 0,
                onSelected: (_) {},
                items: const <LiquidGlassTabItem>[
                  LiquidGlassTabItem(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                    nativeSymbol: 'house',
                  ),
                  LiquidGlassTabItem(
                    icon: Icon(Icons.book),
                    label: Text('Books'),
                    nativeSymbol: 'book',
                  ),
                ],
              ),
              body: Builder(
                builder: (context) {
                  capturedPadding = LiquidGlassScaffold.scrollBottomPadding(
                    context,
                    base: 12,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedPadding, LiquidGlassTabBar.nativeContentHeight + 34 + 12);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('missing native tab symbols keep Flutter tab bar on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassTabBar(
              selectedIndex: 0,
              onSelected: (_) {},
              items: const <LiquidGlassTabItem>[
                LiquidGlassTabItem(icon: Icon(Icons.home), label: Text('Home')),
                LiquidGlassTabItem(
                  icon: Icon(Icons.book),
                  label: Text('Books'),
                ),
              ],
            ),
          ),
        ),
      );

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        isNot(contains(LiquidGlassPlatform.tabBarViewType)),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('non-text tab labels keep Flutter tab bar on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassTabBar(
              selectedIndex: 0,
              onSelected: (_) {},
              items: const <LiquidGlassTabItem>[
                LiquidGlassTabItem(
                  icon: Icon(Icons.home),
                  label: SizedBox(child: Text('Custom')),
                  nativeSymbol: 'house',
                ),
                LiquidGlassTabItem(
                  icon: Icon(Icons.book),
                  label: Text('Books'),
                  nativeSymbol: 'book',
                ),
              ],
            ),
          ),
        ),
      );

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(
        views.map((view) => view.viewType),
        isNot(contains(LiquidGlassPlatform.tabBarViewType)),
      );
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'sheet scaffold keeps modal role with custom configuration on iOS',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LiquidGlassSheetScaffold(
                configuration: LiquidGlassConfiguration(cornerRadius: 22),
                child: Text('Sheet'),
              ),
            ),
          ),
        );

        expect(find.byType(UiKitView), findsOneWidget);
        expect(find.text('Sheet'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

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

  testWidgets('alert falls back when native presentation fails on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          throw PlatformException(code: 'presentation_busy');
        });

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: LiquidGlassButton(
                  onPressed: () {
                    showLiquidGlassAlert(
                      context: context,
                      title: 'Confirm change',
                      message: 'Fallback alert',
                      actions: const <LiquidGlassAction>[
                        LiquidGlassAction(title: 'OK', value: 'ok'),
                      ],
                    );
                  },
                  child: const Text('Show alert'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show alert'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm change'), findsOneWidget);
      expect(find.text('Fallback alert'), findsOneWidget);
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(LiquidGlassPlatform.channel, null);
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('action sheet falls back when native presentation fails on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          throw PlatformException(code: 'presentation_busy');
        });

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: LiquidGlassButton(
                  onPressed: () {
                    showLiquidGlassActionSheet(
                      context: context,
                      title: 'Choose action',
                      message: 'Fallback sheet',
                      actions: const <LiquidGlassAction>[
                        LiquidGlassAction(title: 'Continue', value: 'continue'),
                      ],
                    );
                  },
                  child: const Text('Show sheet'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Choose action'), findsOneWidget);
      expect(find.text('Fallback sheet'), findsOneWidget);
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(LiquidGlassPlatform.channel, null);
      debugDefaultTargetPlatformOverride = null;
    }
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

  testWidgets('native tab bar tap calls Flutter selection handler', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final tabBarKey = GlobalKey<LiquidGlassTabBarState>();
    var selectedIndex = 0;

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassTabBar(
              key: tabBarKey,
              selectedIndex: selectedIndex,
              onSelected: (index) => selectedIndex = index,
              items: const <LiquidGlassTabItem>[
                LiquidGlassTabItem(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  nativeSymbol: 'house',
                ),
                LiquidGlassTabItem(
                  icon: Icon(Icons.book),
                  label: Text('Books'),
                  nativeSymbol: 'book',
                ),
              ],
            ),
          ),
        ),
      );

      await tabBarKey.currentState!.handleMethodCall(
        const MethodCall('onTap', 1),
      );

      expect(selectedIndex, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tab items expose native labels and symbols', (tester) async {
    const item = LiquidGlassTabItem(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Home'),
      nativeSymbol: 'house',
      nativeSelectedSymbol: 'house.fill',
    );

    expect(item.toPlatformMap(), <String, Object>{
      'label': 'Home',
      'symbol': 'house',
      'selectedSymbol': 'house.fill',
    });
  });

  testWidgets('tab item native representation requires symbol and label', (
    tester,
  ) async {
    const bridgeable = LiquidGlassTabItem(
      icon: Icon(Icons.home),
      label: SizedBox.shrink(),
      semanticLabel: 'Home',
      nativeSymbol: 'house',
    );
    const emptySymbol = LiquidGlassTabItem(
      icon: Icon(Icons.home),
      label: Text('Home'),
      nativeSymbol: '',
    );
    const emptyLabel = LiquidGlassTabItem(
      icon: Icon(Icons.home),
      label: SizedBox.shrink(),
      nativeSymbol: 'house',
    );

    expect(bridgeable.isNativeRepresentable, isTrue);
    expect(emptySymbol.isNativeRepresentable, isFalse);
    expect(emptyLabel.isNativeRepresentable, isFalse);
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

  testWidgets('controls use Flutter material in automatic mode on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                LiquidGlassSlider(value: 0.4, onChanged: (_) {}),
                LiquidGlassSwitch(value: true, onChanged: (_) {}),
                LiquidGlassSegmentedControl(
                  selectedIndex: 0,
                  onChanged: (_) {},
                  segments: const <LiquidGlassSegment>[
                    LiquidGlassSegment(label: 'One'),
                    LiquidGlassSegment(label: 'Two'),
                  ],
                ),
                LiquidGlassStepper(value: 1, onChanged: (_) {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(UiKitView), findsNothing);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('controls can opt into native views on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                LiquidGlassSlider(
                  value: 0.4,
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
                  value: 1,
                  nativePolicy: LiquidGlassNativePolicy.native,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(UiKitView), findsNWidgets(4));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('menu button can opt into native UIMenu view on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassMenuButton(
              title: 'Density',
              value: 'comfortable',
              nativePolicy: LiquidGlassNativePolicy.native,
              onChanged: (_) {},
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Compact', value: 'compact'),
                LiquidGlassAction(title: 'Comfortable', value: 'comfortable'),
              ],
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.viewType, LiquidGlassPlatform.menuButtonViewType);
      expect(view.gestureRecognizers, isNotNull);
      expect(view.gestureRecognizers, isNotEmpty);

      final recognizer = view.gestureRecognizers!.first.constructor();
      addTearDown(recognizer.dispose);
      expect(recognizer, isA<EagerGestureRecognizer>());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native menu button selection calls Flutter handler', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final menuKey = GlobalKey<LiquidGlassMenuButtonState>();
    var selectedValue = 'comfortable';

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassMenuButton(
              key: menuKey,
              title: 'Density',
              value: selectedValue,
              nativePolicy: LiquidGlassNativePolicy.native,
              onChanged: (value) => selectedValue = value,
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Compact', value: 'compact'),
                LiquidGlassAction(title: 'Comfortable', value: 'comfortable'),
              ],
            ),
          ),
        ),
      );

      await menuKey.currentState!.handleMethodCall(
        const MethodCall('onChanged', 'compact'),
      );

      expect(selectedValue, 'compact');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'pull-down button uses native UIMenu without selected state on iOS',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidGlassPullDownButton(
                title: 'More',
                nativePolicy: LiquidGlassNativePolicy.native,
                onSelected: (_) {},
                actions: const <LiquidGlassAction>[
                  LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                  LiquidGlassAction(title: 'Archive', value: 'archive'),
                ],
              ),
            ),
          ),
        );

        final view = tester.widget<UiKitView>(find.byType(UiKitView));
        final params = view.creationParams as Map<Object?, Object?>;
        expect(view.viewType, LiquidGlassPlatform.menuButtonViewType);
        expect(params['title'], 'More');
        expect(params['value'], '');
        expect(params['tracksSelection'], isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('native pull-down button action calls Flutter handler', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var selectedAction = '';

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassPullDownButton(
              title: 'More',
              nativePolicy: LiquidGlassNativePolicy.native,
              onSelected: (value) => selectedAction = value,
              actions: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                LiquidGlassAction(title: 'Archive', value: 'archive'),
              ],
            ),
          ),
        ),
      );

      final state = tester.state<LiquidGlassMenuButtonState>(
        find.byType(LiquidGlassMenuButton),
      );
      await state.handleMethodCall(const MethodCall('onChanged', 'archive'));

      expect(selectedAction, 'archive');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('pull-down button can present a native icon action menu on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassPullDownButton(
              title: 'Actions',
              icon: const Icon(Icons.more_horiz_rounded),
              nativeSymbol: 'ellipsis.circle',
              showTitle: false,
              nativePolicy: LiquidGlassNativePolicy.native,
              onSelected: (_) {},
              actions: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                LiquidGlassAction(title: 'Archive', value: 'archive'),
              ],
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      final params = view.creationParams as Map<Object?, Object?>;
      expect(view.viewType, LiquidGlassPlatform.menuButtonViewType);
      expect(params['title'], 'Actions');
      expect(params['symbol'], 'ellipsis.circle');
      expect(params['showsTitle'], isFalse);
      expect(params['tracksSelection'], isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'native icon action menu uses a compact square host view on iOS',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: LiquidGlassPullDownButton(
                  title: 'Actions',
                  icon: const Icon(Icons.more_horiz_rounded),
                  nativeSymbol: 'ellipsis.circle',
                  showTitle: false,
                  nativePolicy: LiquidGlassNativePolicy.native,
                  onSelected: (_) {},
                  actions: const <LiquidGlassAction>[
                    LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.byType(UiKitView)), const Size(50, 50));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('native control views route gestures eagerly on iOS', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                LiquidGlassSlider(
                  value: 0.4,
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
                  value: 1,
                  nativePolicy: LiquidGlassNativePolicy.native,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      expect(views, hasLength(4));
      for (final view in views) {
        final recognizers = view.gestureRecognizers;
        expect(recognizers, isNotNull);
        expect(recognizers, isNotEmpty);

        final recognizer = recognizers!.first.constructor();
        addTearDown(recognizer.dispose);
        expect(recognizer, isA<EagerGestureRecognizer>());
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
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
