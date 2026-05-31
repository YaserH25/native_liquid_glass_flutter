import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/liquid_glass_platform.dart';

Future<DateTime?> showLiquidGlassDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String? title,
  String confirmTitle = 'Done',
  String cancelTitle = 'Cancel',
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    try {
      return await platform.showDatePicker(
        initialDate: initialDate,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        title: title,
        confirmTitle: confirmTitle,
        cancelTitle: cancelTitle,
      );
    } on PlatformException {
      if (!context.mounted) {
        return null;
      }
    }
  }

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: minimumDate ?? DateTime(1900),
    lastDate: maximumDate ?? DateTime(2100),
    helpText: title,
    confirmText: confirmTitle,
    cancelText: cancelTitle,
  );
}
