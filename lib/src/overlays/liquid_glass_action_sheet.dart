import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controls/liquid_glass_button.dart';
import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_action.dart';
import 'liquid_glass_sheet.dart';
import 'liquid_glass_sheet_scaffold.dart';

Future<String?> showLiquidGlassActionSheet({
  required BuildContext context,
  required String title,
  String? message,
  required List<LiquidGlassAction> actions,
  String cancelTitle = 'Cancel',
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
  EdgeInsetsGeometry margin = LiquidGlassOverlayDefaults.sheetMargin,
  EdgeInsetsGeometry padding = LiquidGlassOverlayDefaults.sheetPadding,
  EdgeInsetsGeometry handleMargin =
      LiquidGlassOverlayDefaults.sheetHandleMargin,
  double headerSpacing = LiquidGlassOverlayDefaults.sheetHeaderSpacing,
  EdgeInsetsGeometry messagePadding =
      LiquidGlassOverlayDefaults.actionSheetMessagePadding,
  double actionSpacing = LiquidGlassOverlayDefaults.actionSheetActionSpacing,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    try {
      return await platform.showActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelTitle: cancelTitle,
      );
    } on PlatformException {
      if (!context.mounted) {
        return null;
      }
    }
  }

  return showLiquidGlassSheet<String>(
    context: context,
    title: Text(title),
    margin: margin,
    padding: padding,
    handleMargin: handleMargin,
    headerSpacing: headerSpacing,
    builder: (sheetContext) {
      return LiquidGlassActionSheet(
        message: message,
        actions: actions,
        cancelTitle: cancelTitle,
        messagePadding: messagePadding,
        actionSpacing: actionSpacing,
      );
    },
  );
}

class LiquidGlassActionSheet extends StatelessWidget {
  const LiquidGlassActionSheet({
    super.key,
    required this.actions,
    required this.cancelTitle,
    this.message,
    this.messagePadding = LiquidGlassOverlayDefaults.actionSheetMessagePadding,
    this.actionSpacing = LiquidGlassOverlayDefaults.actionSheetActionSpacing,
  });

  final String? message;
  final List<LiquidGlassAction> actions;
  final String cancelTitle;
  final EdgeInsetsGeometry messagePadding;
  final double actionSpacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cancelAction = actions
        .where((action) => action.role == LiquidGlassActionRole.cancel)
        .firstOrNull;
    final visibleActions = actions.where((action) => action != cancelAction);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (message != null)
          Padding(
            padding: messagePadding,
            child: Text(message!, style: textTheme.bodyMedium),
          ),
        for (final action in visibleActions) ...<Widget>[
          LiquidGlassButton(
            prominent: action.role == LiquidGlassActionRole.preferred,
            onPressed: () => Navigator.of(context).pop(action.value),
            child: Text(action.title, textAlign: TextAlign.center),
          ),
          SizedBox(height: actionSpacing),
        ],
        LiquidGlassButton(
          onPressed: () => Navigator.of(context).pop(cancelAction?.value),
          child: Text(
            cancelAction?.title ?? cancelTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
