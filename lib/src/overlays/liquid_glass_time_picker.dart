import 'package:flutter/material.dart';

import '../platform/liquid_glass_platform.dart';

Future<TimeOfDay?> showLiquidGlassTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? title,
  String confirmTitle = 'Done',
  String cancelTitle = 'Cancel',
  int minuteInterval = 1,
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    return platform.showTimePicker(
      initialTime: initialTime,
      title: title,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
      minuteInterval: minuteInterval,
    );
  }

  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: title,
    confirmText: confirmTitle,
    cancelText: cancelTitle,
  );
}
