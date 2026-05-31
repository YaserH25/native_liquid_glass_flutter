import 'package:flutter/material.dart';

enum LiquidGlassIntensity { subtle, regular, prominent }

@immutable
class LiquidGlassConfiguration {
  const LiquidGlassConfiguration({
    this.preferNative = true,
    this.intensity = LiquidGlassIntensity.regular,
    this.tintColor,
    this.tintOpacity = 0.16,
    this.blurSigma = 22,
    this.cornerRadius = 28,
    this.strokeOpacity = 0.18,
    this.shadowOpacity = 0.12,
    this.interactive = false,
  });

  final bool preferNative;
  final LiquidGlassIntensity intensity;
  final Color? tintColor;
  final double tintOpacity;
  final double blurSigma;
  final double cornerRadius;
  final double strokeOpacity;
  final double shadowOpacity;
  final bool interactive;

  LiquidGlassConfiguration copyWith({
    bool? preferNative,
    LiquidGlassIntensity? intensity,
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
      intensity: intensity ?? this.intensity,
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
      'preferNative': preferNative,
      'intensity': intensity.name,
      'tintColor': tintColor?.toARGB32(),
      'tintOpacity': tintOpacity,
      'blurSigma': blurSigma,
      'cornerRadius': cornerRadius,
      'strokeOpacity': strokeOpacity,
      'shadowOpacity': shadowOpacity,
      'interactive': interactive,
    };
  }
}
