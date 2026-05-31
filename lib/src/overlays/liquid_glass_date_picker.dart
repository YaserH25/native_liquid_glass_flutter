import 'package:flutter/material.dart';

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
    return platform.showDatePicker(
      initialDate: initialDate,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      title: title,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
    );
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
