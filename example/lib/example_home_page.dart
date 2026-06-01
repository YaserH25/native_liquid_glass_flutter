import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'widgets/configuration_showcase.dart';
import 'widgets/native_controls_showcase.dart';
import 'widgets/overlay_showcase.dart';

const int _initialSelectedIndex = int.fromEnvironment('NLGF_INITIAL_TAB');
const bool _initialRtl = bool.fromEnvironment('NLGF_INITIAL_RTL');
const String _initialLocaleCode = String.fromEnvironment(
  'NLGF_INITIAL_LOCALE',
  defaultValue: 'en',
);

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => ExampleHomePageState();
}

class ExampleHomePageState extends State<ExampleHomePage> {
  int selectedIndex = _validInitialSelectedIndex;
  Locale locale = _initialLocaleCode == 'ar'
      ? const Locale('ar')
      : const Locale('en');
  TextDirection textDirection = _initialRtl
      ? TextDirection.rtl
      : TextDirection.ltr;

  static const List<String> pageTitles = <String>[
    'Controls',
    'Overlays',
    'Config',
  ];

  static int get _validInitialSelectedIndex {
    if (_initialSelectedIndex < 0 ||
        _initialSelectedIndex >= pageTitles.length) {
      return 0;
    }
    return _initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: locale,
      child: Directionality(
        textDirection: textDirection,
        child: LiquidGlassScaffold(
          appBar: LiquidGlassAppBar(title: Text(pageTitles[selectedIndex])),
          bottomNavigationBar: LiquidGlassTabBar(
            selectedIndex: selectedIndex,
            onSelected: (index) => setState(() => selectedIndex = index),
            items: const <LiquidGlassTabItem>[
              LiquidGlassTabItem(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune_rounded),
                label: Text('Controls'),
                nativeSymbol: 'slider.horizontal.3',
                nativeSelectedSymbol: 'slider.horizontal.3',
              ),
              LiquidGlassTabItem(
                icon: Icon(Icons.ios_share_outlined),
                selectedIcon: Icon(Icons.ios_share_rounded),
                label: Text('Overlays'),
                nativeSymbol: 'square.and.arrow.up',
                nativeSelectedSymbol: 'square.and.arrow.up',
              ),
              LiquidGlassTabItem(
                icon: Icon(Icons.palette_outlined),
                selectedIcon: Icon(Icons.palette_rounded),
                label: Text('Config'),
                nativeSymbol: 'paintpalette',
                nativeSelectedSymbol: 'paintpalette.fill',
              ),
            ],
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: <Widget>[
              const NativeControlsShowcase(),
              const OverlayShowcase(),
              ConfigurationShowcase(
                textDirection: textDirection,
                locale: locale,
                onTextDirectionChanged: updateTextDirection,
                onLocaleChanged: updateLocale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateTextDirection(TextDirection value) {
    setState(() => textDirection = value);
  }

  void updateLocale(Locale value) {
    setState(() => locale = value);
  }
}
