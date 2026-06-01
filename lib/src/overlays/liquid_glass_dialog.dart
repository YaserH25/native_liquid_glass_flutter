import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controls/liquid_glass_button.dart';
import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_action.dart';
import 'liquid_glass_sheet_scaffold.dart';

Future<String?> showLiquidGlassAlert({
  required BuildContext context,
  required String title,
  String? message,
  required List<LiquidGlassAction> actions,
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
  EdgeInsets? insetPadding,
  EdgeInsetsGeometry padding = LiquidGlassOverlayDefaults.dialogPadding,
  EdgeInsetsGeometry messagePadding =
      LiquidGlassOverlayDefaults.dialogMessagePadding,
  double actionSpacing = LiquidGlassOverlayDefaults.dialogActionSpacing,
  double actionRunSpacing = LiquidGlassOverlayDefaults.dialogActionRunSpacing,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    try {
      return await platform.showAlert(
        title: title,
        message: message,
        actions: actions,
      );
    } on PlatformException {
      if (!context.mounted) {
        return null;
      }
    }
  }

  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: insetPadding,
        child: LiquidGlassDialog(
          title: title,
          message: message,
          actions: actions,
          padding: padding,
          messagePadding: messagePadding,
          actionSpacing: actionSpacing,
          actionRunSpacing: actionRunSpacing,
        ),
      );
    },
  );
}

class LiquidGlassDialog extends StatelessWidget {
  const LiquidGlassDialog({
    super.key,
    required this.title,
    required this.actions,
    this.message,
    this.padding = LiquidGlassOverlayDefaults.dialogPadding,
    this.messagePadding = LiquidGlassOverlayDefaults.dialogMessagePadding,
    this.actionSpacing = LiquidGlassOverlayDefaults.dialogActionSpacing,
    this.actionRunSpacing = LiquidGlassOverlayDefaults.dialogActionRunSpacing,
  });

  final String title;
  final String? message;
  final List<LiquidGlassAction> actions;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry messagePadding;
  final double actionSpacing;
  final double actionRunSpacing;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSheetScaffold(
      showHandle: false,
      title: Text(title),
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (message != null)
            Padding(padding: messagePadding, child: Text(message!)),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: actionSpacing,
            runSpacing: actionRunSpacing,
            children: actions.map((action) {
              return LiquidGlassButton(
                prominent: action.role == LiquidGlassActionRole.preferred,
                onPressed: () => Navigator.of(context).pop(action.value),
                child: Text(action.title),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
