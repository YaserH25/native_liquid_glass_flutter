import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_action.dart';
import 'liquid_glass_action_sheet.dart';

Future<String?> showLiquidGlassOptionPicker({
  required BuildContext context,
  required String title,
  String? message,
  required List<LiquidGlassAction> options,
  String cancelTitle = 'Cancel',
  LiquidGlassPlatform platform = const LiquidGlassPlatform(),
  bool useNativeOnIOS = true,
}) async {
  if (useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
    try {
      return await platform.showOptionPicker(
        title: title,
        message: message,
        options: options,
        cancelTitle: cancelTitle,
      );
    } on PlatformException {
      if (!context.mounted) {
        return null;
      }
    }
  }

  return showLiquidGlassActionSheet(
    context: context,
    title: title,
    message: message,
    actions: options,
    cancelTitle: cancelTitle,
    platform: platform,
    useNativeOnIOS: false,
  );
}

class LiquidGlassPickerButton extends StatelessWidget {
  const LiquidGlassPickerButton({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.message,
    this.cancelTitle = 'Cancel',
  });

  final String title;
  final String value;
  final List<LiquidGlassAction> options;
  final ValueChanged<String> onChanged;
  final String? message;
  final String cancelTitle;

  @override
  Widget build(BuildContext context) {
    LiquidGlassAction? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: selected == null ? null : Text(selected.title),
      trailing: const Icon(Icons.keyboard_arrow_down_rounded),
      onTap: () async {
        final selectedValue = await showLiquidGlassOptionPicker(
          context: context,
          title: title,
          message: message,
          options: options,
          cancelTitle: cancelTitle,
        );

        if (selectedValue != null) {
          onChanged(selectedValue);
        }
      },
    );
  }
}
