import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';
import 'showcase_list.dart';

class ConfigurationShowcase extends StatefulWidget {
  const ConfigurationShowcase({super.key});

  @override
  State<ConfigurationShowcase> createState() => ConfigurationShowcaseState();
}

class ConfigurationShowcaseState extends State<ConfigurationShowcase> {
  double radius = 30;
  double tintOpacity = 0.16;

  @override
  Widget build(BuildContext context) {
    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Configurable surface',
          subtitle: 'The same Dart API drives native iOS and Flutter fallback.',
          children: <Widget>[
            LiquidGlassSurface(
              configuration: LiquidGlassConfiguration(
                cornerRadius: radius,
                tintOpacity: tintOpacity,
                interactive: true,
              ),
              padding: const EdgeInsets.all(18),
              child: const Text('Tune radius and tint opacity below.'),
            ),
            const SizedBox(height: 16),
            Text('Corner radius: ${radius.round()}'),
            LiquidGlassSlider(
              value: radius,
              min: 14,
              max: 44,
              onChanged: (value) => setState(() => radius = value),
            ),
            Text('Tint opacity: ${tintOpacity.toStringAsFixed(2)}'),
            LiquidGlassSlider(
              value: tintOpacity,
              min: 0.04,
              max: 0.36,
              onChanged: (value) => setState(() => tintOpacity = value),
            ),
          ],
        ),
      ],
    );
  }
}
