import 'package:flutter/material.dart';

import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_policy.dart';

enum LiquidGlassIntensity { subtle, regular, prominent }

enum LiquidGlassCornerStyle { all, top, none }

@immutable
class LiquidGlassConfiguration {
  const LiquidGlassConfiguration({
    this.preferNative = true,
    this.nativePolicy = LiquidGlassNativePolicy.automatic,
    this.role = LiquidGlassSurfaceRole.content,
    this.intensity = LiquidGlassIntensity.regular,
    this.cornerStyle = LiquidGlassCornerStyle.all,
    this.tintColor,
    this.tintOpacity = 0.16,
    this.blurSigma = 22,
    this.cornerRadius = 28,
    this.strokeOpacity = 0.18,
    this.shadowOpacity = 0.12,
    this.interactive = false,
  });

  final bool preferNative;
  final LiquidGlassNativePolicy nativePolicy;
  final LiquidGlassSurfaceRole role;
  final LiquidGlassIntensity intensity;
  final LiquidGlassCornerStyle cornerStyle;
  final Color? tintColor;
  final double tintOpacity;
  final double blurSigma;
  final double cornerRadius;
  final double strokeOpacity;
  final double shadowOpacity;
  final bool interactive;

  LiquidGlassNativePolicy get resolvedNativePolicy {
    return preferNative ? nativePolicy : LiquidGlassNativePolicy.flutter;
  }

  LiquidGlassConfiguration copyWith({
    bool? preferNative,
    LiquidGlassNativePolicy? nativePolicy,
    LiquidGlassSurfaceRole? role,
    LiquidGlassIntensity? intensity,
    LiquidGlassCornerStyle? cornerStyle,
    Color? tintColor,
    double? tintOpacity,
    double? blurSigma,
    double? cornerRadius,
    double? strokeOpacity,
    double? shadowOpacity,
    bool? interactive,
  }) {
    return LiquidGlassConfiguration(
      preferNative: preferNative ?? this.preferNative,
      nativePolicy: nativePolicy ?? this.nativePolicy,
      role: role ?? this.role,
      intensity: intensity ?? this.intensity,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      tintColor: tintColor ?? this.tintColor,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      blurSigma: blurSigma ?? this.blurSigma,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      strokeOpacity: strokeOpacity ?? this.strokeOpacity,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      interactive: interactive ?? this.interactive,
    );
  }

  Map<String, Object?> toPlatformMap() {
    return <String, Object?>{
      LiquidGlassBridgeKeys.preferNative: preferNative,
      LiquidGlassBridgeKeys.nativePolicy: resolvedNativePolicy.name,
      LiquidGlassBridgeKeys.role: role.name,
      LiquidGlassBridgeKeys.intensity: intensity.name,
      LiquidGlassBridgeKeys.cornerStyle: cornerStyle.name,
      LiquidGlassBridgeKeys.tintColor: tintColor?.toARGB32(),
      LiquidGlassBridgeKeys.tintOpacity: tintOpacity,
      LiquidGlassBridgeKeys.blurSigma: blurSigma,
      LiquidGlassBridgeKeys.cornerRadius: cornerRadius,
      LiquidGlassBridgeKeys.strokeOpacity: strokeOpacity,
      LiquidGlassBridgeKeys.shadowOpacity: shadowOpacity,
      LiquidGlassBridgeKeys.interactive: interactive,
    };
  }
}
