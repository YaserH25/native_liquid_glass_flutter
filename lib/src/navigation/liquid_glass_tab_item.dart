import 'package:flutter/widgets.dart';

import '../platform/liquid_glass_bridge_keys.dart';

@immutable
class LiquidGlassTabItem {
  const LiquidGlassTabItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.semanticLabel,
    this.nativeSymbol,
    this.nativeSelectedSymbol,
  });

  final Widget icon;
  final Widget label;
  final Widget? selectedIcon;
  final String? semanticLabel;
  final String? nativeSymbol;
  final String? nativeSelectedSymbol;

  bool get isNativeRepresentable {
    return nativeSymbol?.isNotEmpty == true && platformLabel.trim().isNotEmpty;
  }

  Map<String, Object> toPlatformMap() {
    assert(
      isNativeRepresentable,
      'LiquidGlassTabItem requires nativeSymbol and a text or semantic label '
      'when rendered by native UITabBar.',
    );
    final symbol = nativeSymbol ?? 'circle';

    return <String, Object>{
      LiquidGlassBridgeKeys.label: platformLabel,
      LiquidGlassBridgeKeys.symbol: symbol,
      LiquidGlassBridgeKeys.selectedSymbol: nativeSelectedSymbol ?? symbol,
    };
  }

  String get platformLabel {
    final semanticLabel = this.semanticLabel;
    if (semanticLabel != null && semanticLabel.isNotEmpty) {
      return semanticLabel;
    }

    final label = this.label;
    if (label is Text) {
      final data = label.data;
      if (data != null) {
        return data;
      }
    }

    return '';
  }
}
