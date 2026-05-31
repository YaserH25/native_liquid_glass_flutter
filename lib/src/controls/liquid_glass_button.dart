import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../surfaces/liquid_glass_surface.dart';

class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.configuration,
    this.prominent = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final LiquidGlassConfiguration? configuration;
  final bool prominent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final enabled = onPressed != null;
    final foreground = prominent
        ? theme.accentColor
        : theme.foregroundColor.withValues(alpha: enabled ? 1 : 0.42);

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: LiquidGlassSurface(
          configuration:
              configuration ??
              theme.surface.copyWith(
                interactive: enabled,
                tintColor: prominent
                    ? theme.accentColor
                    : theme.surface.tintColor,
                tintOpacity: prominent ? 0.18 : theme.surface.tintOpacity,
              ),
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
