import 'package:flutter/foundation.dart';

import '../overlays/liquid_glass_action.dart';
import '../platform/liquid_glass_bridge_keys.dart';

@immutable
class LiquidGlassAppBarAction {
  const LiquidGlassAppBarAction({
    required this.title,
    required this.value,
    this.nativeSymbol,
    this.role = LiquidGlassActionRole.normal,
    this.enabled = true,
    this.menuActions = const <LiquidGlassAction>[],
  });

  final String title;
  final String value;
  final String? nativeSymbol;
  final LiquidGlassActionRole role;
  final bool enabled;
  final List<LiquidGlassAction> menuActions;

  Map<String, Object?> toPlatformMap() {
    final map = <String, Object?>{
      LiquidGlassBridgeKeys.title: title,
      LiquidGlassBridgeKeys.value: value,
      LiquidGlassBridgeKeys.role: role.name,
      LiquidGlassBridgeKeys.enabled: enabled,
    };
    final nativeSymbol = this.nativeSymbol;
    if (nativeSymbol != null) {
      map[LiquidGlassBridgeKeys.symbol] = nativeSymbol;
    }
    if (menuActions.isNotEmpty) {
      map[LiquidGlassBridgeKeys.actions] = menuActions
          .map((action) => action.toPlatformMap())
          .toList();
    }
    return map;
  }
}
