import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../surfaces/liquid_glass_surface.dart';

class LiquidGlassOverlayDefaults {
  const LiquidGlassOverlayDefaults._();

  static const EdgeInsetsGeometry sheetMargin = EdgeInsets.all(8);
  static const EdgeInsetsGeometry sheetPadding = EdgeInsets.fromLTRB(
    20,
    10,
    20,
    20,
  );
  static const EdgeInsetsGeometry sheetHandleMargin = EdgeInsets.only(
    bottom: 14,
  );
  static const double sheetHeaderSpacing = 16;
  static const EdgeInsetsGeometry dialogPadding = EdgeInsets.fromLTRB(
    20,
    10,
    20,
    20,
  );
  static const EdgeInsetsGeometry dialogMessagePadding = EdgeInsets.only(
    bottom: 16,
  );
  static const double dialogActionSpacing = 8;
  static const double dialogActionRunSpacing = 8;
  static const EdgeInsetsGeometry actionSheetMessagePadding = EdgeInsets.only(
    bottom: 12,
  );
  static const double actionSheetActionSpacing = 8;
}

class LiquidGlassSheetScaffold extends StatelessWidget {
  const LiquidGlassSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions = const <Widget>[],
    this.configuration,
    this.margin = LiquidGlassOverlayDefaults.sheetMargin,
    this.padding = LiquidGlassOverlayDefaults.sheetPadding,
    this.handleMargin = LiquidGlassOverlayDefaults.sheetHandleMargin,
    this.headerSpacing = LiquidGlassOverlayDefaults.sheetHeaderSpacing,
    this.showHandle = true,
  });

  final Widget child;
  final Widget? title;
  final List<Widget> actions;
  final LiquidGlassConfiguration? configuration;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry handleMargin;
  final double headerSpacing;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final surfaceConfiguration =
        configuration ?? theme.surface.copyWith(cornerRadius: 34);

    return LiquidGlassSurface(
      margin: margin,
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
                margin: handleMargin,
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
          if (title != null || actions.isNotEmpty)
            SizedBox(height: headerSpacing),
          child,
        ],
      ),
    );
  }
}
