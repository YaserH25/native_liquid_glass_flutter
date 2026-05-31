import 'package:flutter/widgets.dart';

@immutable
class LiquidGlassTabItem {
  const LiquidGlassTabItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.semanticLabel,
  });

  final Widget icon;
  final Widget label;
  final Widget? selectedIcon;
  final String? semanticLabel;
}
