import 'package:flutter/material.dart';

import '../controls/liquid_glass_button.dart';
import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_action.dart';
import 'liquid_glass_sheet.dart';

Future<String?> showLiquidGlassActionSheet({
  required BuildContext context,
  required String title,
  String? message,
  required List<LiquidGlassAction> actions,
  String cancelTitle = 'Cancel',
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    return platform.showActionSheet(
      title: title,
      message: message,
      actions: actions,
      cancelTitle: cancelTitle,
    );
  }

  return showLiquidGlassSheet<String>(
    context: context,
    title: Text(title),
    builder: (sheetContext) {
      return LiquidGlassActionSheet(
        message: message,
        actions: actions,
        cancelTitle: cancelTitle,
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
  });

  final String? message;
  final List<LiquidGlassAction> actions;
  final String cancelTitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(message!, style: textTheme.bodyMedium),
          ),
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LiquidGlassButton(
              prominent: action.role == LiquidGlassActionRole.preferred,
              onPressed: () => Navigator.of(context).pop(action.value),
              child: Text(action.title, textAlign: TextAlign.center),
            ),
          ),
        LiquidGlassButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelTitle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
