import 'package:flutter/foundation.dart';

import '../platform/liquid_glass_bridge_keys.dart';

enum LiquidGlassActionRole { normal, preferred, destructive, cancel }

@immutable
class LiquidGlassAction {
  const LiquidGlassAction({
    required this.title,
    required this.value,
    this.role = LiquidGlassActionRole.normal,
  });

  final String title;
  final String value;
  final LiquidGlassActionRole role;

  Map<String, Object?> toPlatformMap() {
    return <String, Object?>{
      LiquidGlassBridgeKeys.title: title,
      LiquidGlassBridgeKeys.value: value,
      LiquidGlassBridgeKeys.role: role.name,
    };
  }
}
