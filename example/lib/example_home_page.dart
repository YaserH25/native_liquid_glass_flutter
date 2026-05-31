import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'widgets/configuration_showcase.dart';
import 'widgets/native_controls_showcase.dart';
import 'widgets/overlay_showcase.dart';

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => ExampleHomePageState();
}

class ExampleHomePageState extends State<ExampleHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScaffold(
      appBar: const LiquidGlassAppBar(center: Icon(Icons.auto_awesome_rounded)),
      bottomNavigationBar: LiquidGlassTabBar(
        selectedIndex: selectedIndex,
        onSelected: (index) => setState(() => selectedIndex = index),
        items: const <LiquidGlassTabItem>[
          LiquidGlassTabItem(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: Text('Controls'),
          ),
          LiquidGlassTabItem(
            icon: Icon(Icons.ios_share_outlined),
            selectedIcon: Icon(Icons.ios_share_rounded),
            label: Text('Overlays'),
          ),
          LiquidGlassTabItem(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette_rounded),
            label: Text('Config'),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const <Widget>[
          NativeControlsShowcase(),
          OverlayShowcase(),
          ConfigurationShowcase(),
        ],
      ),
    );
  }
}
