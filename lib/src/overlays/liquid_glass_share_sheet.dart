import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/liquid_glass_platform.dart';

Future<bool?> showLiquidGlassShareSheet({
  required BuildContext context,
  required List<String> items,
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    try {
      return await platform.showShareSheet(items: items);
    } on PlatformException {
      if (!context.mounted) {
        return false;
      }
    }
  }

  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    const SnackBar(content: Text('Native share sheet is available on iOS.')),
  );
  return false;
}
