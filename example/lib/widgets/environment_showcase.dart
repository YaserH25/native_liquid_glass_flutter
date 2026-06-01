import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';

class EnvironmentShowcase extends StatelessWidget {
  const EnvironmentShowcase({
    super.key,
    required this.textDirection,
    required this.locale,
    required this.onTextDirectionChanged,
    required this.onLocaleChanged,
  });

  final TextDirection textDirection;
  final Locale locale;
  final ValueChanged<TextDirection> onTextDirectionChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final directionIndex = textDirection == TextDirection.rtl ? 1 : 0;
    final localeIndex = locale.languageCode == 'ar' ? 1 : 0;

    return ExampleSection(
      title: 'App environment',
      subtitle: 'Native views resync when direction or language changes.',
      children: <Widget>[
        Text('Direction: ${directionIndex == 0 ? 'LTR' : 'RTL'}'),
        const SizedBox(height: 10),
        LiquidGlassSegmentedControl(
          selectedIndex: directionIndex,
          onChanged: (index) {
            onTextDirectionChanged(
              index == 0 ? TextDirection.ltr : TextDirection.rtl,
            );
          },
          segments: const <LiquidGlassSegment>[
            LiquidGlassSegment(label: 'LTR'),
            LiquidGlassSegment(label: 'RTL'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Language: ${localeIndex == 0 ? 'English' : 'Arabic'}'),
        const SizedBox(height: 10),
        LiquidGlassSegmentedControl(
          selectedIndex: localeIndex,
          onChanged: (index) {
            onLocaleChanged(
              index == 0 ? const Locale('en') : const Locale('ar'),
            );
          },
          segments: const <LiquidGlassSegment>[
            LiquidGlassSegment(label: 'English'),
            LiquidGlassSegment(label: 'Arabic'),
          ],
        ),
      ],
    );
  }
}
