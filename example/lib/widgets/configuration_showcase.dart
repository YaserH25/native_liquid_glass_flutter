import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';
import 'navigation_showcase.dart';
import 'showcase_list.dart';

class ConfigurationShowcase extends StatefulWidget {
  const ConfigurationShowcase({super.key});

  @override
  State<ConfigurationShowcase> createState() => ConfigurationShowcaseState();
}

class ConfigurationShowcaseState extends State<ConfigurationShowcase> {
  double radius = 30;
  double tintOpacity = 0.16;
  int cornerStyleIndex = 0;

  static const List<LiquidGlassCornerStyle> cornerStyles =
      <LiquidGlassCornerStyle>[
        LiquidGlassCornerStyle.all,
        LiquidGlassCornerStyle.top,
        LiquidGlassCornerStyle.none,
      ];

  @override
  Widget build(BuildContext context) {
    final cornerStyle = cornerStyles[cornerStyleIndex];

    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Glass surface',
          children: <Widget>[
            LiquidGlassSurface(
              configuration: LiquidGlassConfiguration(
                cornerRadius: radius,
                cornerStyle: cornerStyle,
                tintOpacity: tintOpacity,
                interactive: true,
              ),
              padding: const EdgeInsets.all(18),
              child: const Text('Live preview'),
            ),
            const SizedBox(height: 16),
            Text('Corner radius: ${radius.round()}'),
            LiquidGlassSlider(
              value: radius,
              min: 14,
              max: 44,
              onChanged: (value) => setState(() => radius = value),
            ),
            const SizedBox(height: 8),
            Text('Tint opacity: ${tintOpacity.toStringAsFixed(2)}'),
            LiquidGlassSlider(
              value: tintOpacity,
              min: 0.04,
              max: 0.36,
              onChanged: (value) => setState(() => tintOpacity = value),
            ),
            const SizedBox(height: 8),
            Text('Corners: ${cornerStyle.name}'),
            const SizedBox(height: 10),
            LiquidGlassSegmentedControl(
              selectedIndex: cornerStyleIndex,
              onChanged: (index) => setState(() => cornerStyleIndex = index),
              segments: const <LiquidGlassSegment>[
                LiquidGlassSegment(label: 'All'),
                LiquidGlassSegment(label: 'Top'),
                LiquidGlassSegment(label: 'None'),
              ],
            ),
          ],
        ),
        const NavigationShowcase(),
      ],
    );
  }
}
