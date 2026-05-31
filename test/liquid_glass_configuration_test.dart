import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  test('automatic policy keeps content surfaces in Flutter', () {
    const resolver = LiquidGlassNativeResolver(
      isNativeIOS: true,
      policy: LiquidGlassNativePolicy.automatic,
      role: LiquidGlassSurfaceRole.content,
    );

    expect(resolver.usesNativeSurface, false);
  });

  test('automatic policy uses native for chrome surfaces on iOS', () {
    const resolver = LiquidGlassNativeResolver(
      isNativeIOS: true,
      policy: LiquidGlassNativePolicy.automatic,
      role: LiquidGlassSurfaceRole.chrome,
    );

    expect(resolver.usesNativeSurface, true);
  });

  test(
    'automatic policy uses native for floating and modal surfaces on iOS',
    () {
      const floatingResolver = LiquidGlassNativeResolver(
        isNativeIOS: true,
        policy: LiquidGlassNativePolicy.automatic,
        role: LiquidGlassSurfaceRole.floating,
      );
      const modalResolver = LiquidGlassNativeResolver(
        isNativeIOS: true,
        policy: LiquidGlassNativePolicy.automatic,
        role: LiquidGlassSurfaceRole.modal,
      );

      expect(floatingResolver.usesNativeSurface, true);
      expect(modalResolver.usesNativeSurface, true);
    },
  );

  test('native policy falls back when not running on iOS', () {
    const resolver = LiquidGlassNativeResolver(
      isNativeIOS: false,
      policy: LiquidGlassNativePolicy.native,
      role: LiquidGlassSurfaceRole.chrome,
    );

    expect(resolver.usesNativeSurface, false);
  });

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

  test('configuration defaults to automatic content policy', () {
    const configuration = LiquidGlassConfiguration();

    expect(configuration.nativePolicy, LiquidGlassNativePolicy.automatic);
    expect(configuration.role, LiquidGlassSurfaceRole.content);
  });

  test('preferNative false maps to Flutter policy', () {
    const configuration = LiquidGlassConfiguration(preferNative: false);

    expect(configuration.resolvedNativePolicy, LiquidGlassNativePolicy.flutter);
  });

  test('platform map includes native policy and role', () {
    const configuration = LiquidGlassConfiguration(
      nativePolicy: LiquidGlassNativePolicy.native,
      role: LiquidGlassSurfaceRole.modal,
    );

    expect(configuration.toPlatformMap()['nativePolicy'], 'native');
    expect(configuration.toPlatformMap()['role'], 'modal');
  });

  test('platform map includes corner style', () {
    const configuration = LiquidGlassConfiguration(
      cornerStyle: LiquidGlassCornerStyle.top,
    );

    expect(configuration.toPlatformMap()['cornerStyle'], 'top');
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
