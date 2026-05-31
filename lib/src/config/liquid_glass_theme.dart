import 'package:flutter/material.dart';

import 'liquid_glass_configuration.dart';

@immutable
class LiquidGlassThemeData {
  const LiquidGlassThemeData({
    required this.surface,
    required this.foregroundColor,
    required this.mutedForegroundColor,
    required this.accentColor,
    required this.selectedForegroundColor,
    required this.fallbackSurfaceColor,
    this.appBarHeight = 64,
    this.tabBarHeight = 76,
  });

  factory LiquidGlassThemeData.fromColorScheme(ColorScheme colorScheme) {
    final brightness = colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return LiquidGlassThemeData(
      surface: LiquidGlassConfiguration(
        tintColor: isDark ? Colors.white : colorScheme.surface,
        tintOpacity: isDark ? 0.10 : 0.42,
        strokeOpacity: isDark ? 0.16 : 0.26,
        shadowOpacity: isDark ? 0.18 : 0.10,
      ),
      foregroundColor: colorScheme.onSurface,
      mutedForegroundColor: colorScheme.onSurfaceVariant,
      accentColor: colorScheme.primary,
      selectedForegroundColor: colorScheme.primary,
      fallbackSurfaceColor: colorScheme.surface.withValues(
        alpha: isDark ? 0.70 : 0.78,
      ),
    );
  }

  final LiquidGlassConfiguration surface;
  final Color foregroundColor;
  final Color mutedForegroundColor;
  final Color accentColor;
  final Color selectedForegroundColor;
  final Color fallbackSurfaceColor;
  final double appBarHeight;
  final double tabBarHeight;

  LiquidGlassThemeData copyWith({
    LiquidGlassConfiguration? surface,
    Color? foregroundColor,
    Color? mutedForegroundColor,
    Color? accentColor,
    Color? selectedForegroundColor,
    Color? fallbackSurfaceColor,
    double? appBarHeight,
    double? tabBarHeight,
  }) {
    return LiquidGlassThemeData(
      surface: surface ?? this.surface,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      mutedForegroundColor: mutedForegroundColor ?? this.mutedForegroundColor,
      accentColor: accentColor ?? this.accentColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      fallbackSurfaceColor: fallbackSurfaceColor ?? this.fallbackSurfaceColor,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
    );
  }
}

class LiquidGlassTheme extends InheritedWidget {
  const LiquidGlassTheme({super.key, required this.data, required super.child});

  final LiquidGlassThemeData data;

  static LiquidGlassThemeData of(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<LiquidGlassTheme>();
    return theme?.data ??
        LiquidGlassThemeData.fromColorScheme(Theme.of(context).colorScheme);
  }

  @override
  bool updateShouldNotify(LiquidGlassTheme oldWidget) {
    return data != oldWidget.data;
  }
}
