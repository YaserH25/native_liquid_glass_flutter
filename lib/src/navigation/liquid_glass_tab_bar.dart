import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../surfaces/liquid_glass_surface.dart';
import 'liquid_glass_tab_item.dart';

class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.configuration,
    this.height,
    this.iconTextGap = 6,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<LiquidGlassTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final LiquidGlassConfiguration? configuration;
  final double? height;
  final double iconTextGap;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final tabHeight = height ?? theme.tabBarHeight;

    return LiquidGlassSurface(
      height: tabHeight,
      margin: margin,
      padding: const EdgeInsets.all(6),
      configuration:
          configuration ??
          theme.surface.copyWith(
            cornerRadius: tabHeight / 2,
            interactive: true,
          ),
      child: Row(
        children: List<Widget>.generate(items.length, (index) {
          return Expanded(
            child: LiquidGlassTabButton(
              item: items[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
              iconTextGap: iconTextGap,
              padding: itemPadding,
            ),
          );
        }),
      ),
    );
  }
}

class LiquidGlassTabButton extends StatelessWidget {
  const LiquidGlassTabButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    required this.iconTextGap,
    required this.padding,
  });

  final LiquidGlassTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double iconTextGap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final color = selected
        ? theme.selectedForegroundColor
        : theme.foregroundColor;

    return Semantics(
      selected: selected,
      label: item.semanticLabel,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: padding,
          decoration: ShapeDecoration(
            color: selected
                ? theme.accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: color, size: 27),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                height: 1.05,
              ),
              textAlign: TextAlign.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  selected ? item.selectedIcon ?? item.icon : item.icon,
                  SizedBox(height: iconTextGap),
                  item.label,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
