import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../surfaces/liquid_glass_surface.dart';

class LiquidGlassSheetScaffold extends StatelessWidget {
  const LiquidGlassSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions = const <Widget>[],
    this.configuration,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 20),
    this.showHandle = true,
  });

  final Widget child;
  final Widget? title;
  final List<Widget> actions;
  final LiquidGlassConfiguration? configuration;
  final EdgeInsetsGeometry padding;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final surfaceConfiguration =
        configuration ?? theme.surface.copyWith(cornerRadius: 34);

    return LiquidGlassSurface(
      margin: const EdgeInsets.all(8),
      padding: padding,
      configuration: surfaceConfiguration.copyWith(
        role: LiquidGlassSurfaceRole.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showHandle)
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: ShapeDecoration(
                  color: theme.mutedForegroundColor.withValues(alpha: 0.38),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          if (title != null || actions.isNotEmpty)
            Row(
              children: <Widget>[
                if (title != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: theme.foregroundColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      child: title!,
                    ),
                  ),
                ...actions,
              ],
            ),
          if (title != null || actions.isNotEmpty) const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
