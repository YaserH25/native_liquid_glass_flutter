import 'package:flutter/material.dart';

import '../platform/liquid_glass_platform.dart';

Future<bool?> showLiquidGlassShareSheet({
  required BuildContext context,
  required List<String> items,
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    return platform.showShareSheet(items: items);
  }

  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    const SnackBar(content: Text('Native share sheet is available on iOS.')),
  );
  return false;
}
