import 'package:flutter/foundation.dart';

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
    return <String, Object?>{'title': title, 'value': value, 'role': role.name};
  }
}
