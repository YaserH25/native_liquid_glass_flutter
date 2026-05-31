import 'package:flutter/material.dart';

import '../overlays/liquid_glass_action.dart';
import '../platform/liquid_glass_native_policy.dart';
import 'liquid_glass_menu_button.dart';

class LiquidGlassPullDownButton extends StatelessWidget {
  const LiquidGlassPullDownButton({
    super.key,
    required this.title,
    required this.actions,
    required this.onSelected,
    this.message,
    this.cancelTitle = 'Cancel',
    this.height = 50,
    this.width,
    this.enabled = true,
    this.tintColor,
    this.useNativeOnIOS = true,
    this.nativePolicy = LiquidGlassNativePolicy.native,
    this.icon,
    this.nativeSymbol,
    this.showTitle = true,
  });

  final String title;
  final List<LiquidGlassAction> actions;
  final ValueChanged<String> onSelected;
  final String? message;
  final String cancelTitle;
  final double height;
  final double? width;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;
  final Widget? icon;
  final String? nativeSymbol;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassMenuButton(
      title: title,
      value: '',
      options: actions,
      onChanged: onSelected,
      message: message,
      cancelTitle: cancelTitle,
      height: height,
      width: width,
      enabled: enabled,
      tintColor: tintColor,
      useNativeOnIOS: useNativeOnIOS,
      nativePolicy: nativePolicy,
      tracksSelection: false,
      icon: icon,
      nativeSymbol: nativeSymbol,
      showTitle: showTitle,
    );
  }
}
