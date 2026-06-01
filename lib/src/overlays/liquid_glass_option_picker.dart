import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/liquid_glass_platform.dart';
import 'liquid_glass_action.dart';
import 'liquid_glass_action_sheet.dart';
import 'liquid_glass_sheet_scaffold.dart';

Future<String?> showLiquidGlassOptionPicker({
  required BuildContext context,
  required String title,
  String? message,
  required List<LiquidGlassAction> options,
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
    margin: margin,
    padding: padding,
    handleMargin: handleMargin,
    headerSpacing: headerSpacing,
    messagePadding: messagePadding,
    actionSpacing: actionSpacing,
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
    this.margin = LiquidGlassOverlayDefaults.sheetMargin,
    this.padding = LiquidGlassOverlayDefaults.sheetPadding,
    this.handleMargin = LiquidGlassOverlayDefaults.sheetHandleMargin,
    this.headerSpacing = LiquidGlassOverlayDefaults.sheetHeaderSpacing,
    this.messagePadding = LiquidGlassOverlayDefaults.actionSheetMessagePadding,
    this.actionSpacing = LiquidGlassOverlayDefaults.actionSheetActionSpacing,
  });

  final String title;
  final String value;
  final List<LiquidGlassAction> options;
  final ValueChanged<String> onChanged;
  final String? message;
  final String cancelTitle;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry handleMargin;
  final double headerSpacing;
  final EdgeInsetsGeometry messagePadding;
  final double actionSpacing;

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
          margin: margin,
          padding: padding,
          handleMargin: handleMargin,
          headerSpacing: headerSpacing,
          messagePadding: messagePadding,
          actionSpacing: actionSpacing,
        );

        if (selectedValue != null) {
          onChanged(selectedValue);
        }
      },
    );
  }
}
