import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  test('configuration serializes to platform map', () {
    const configuration = LiquidGlassConfiguration(
      tintColor: Color(0xFF007A5A),
      cornerRadius: 32,
      interactive: true,
    );

    expect(configuration.toPlatformMap(), containsPair('cornerRadius', 32));
    expect(configuration.toPlatformMap(), containsPair('interactive', true));
    expect(
      configuration.toPlatformMap(),
      containsPair('tintColor', 0xFF007A5A),
    );
  });

  test('theme copies only provided values', () {
    final base = LiquidGlassThemeData.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.teal),
    );
    final updated = base.copyWith(appBarHeight: 72);

    expect(updated.appBarHeight, 72);
    expect(updated.tabBarHeight, base.tabBarHeight);
    expect(updated.accentColor, base.accentColor);
  });
}
