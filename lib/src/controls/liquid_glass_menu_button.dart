import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../overlays/liquid_glass_action.dart';
import '../overlays/liquid_glass_option_picker.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassMenuButton extends StatefulWidget {
  const LiquidGlassMenuButton({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.message,
    this.cancelTitle = 'Cancel',
    this.height = 50,
    this.enabled = true,
    this.tintColor,
    this.useNativeOnIOS = true,
    this.nativePolicy = LiquidGlassNativePolicy.native,
  });

  final String title;
  final String value;
  final List<LiquidGlassAction> options;
  final ValueChanged<String> onChanged;
  final String? message;
  final String cancelTitle;
  final double height;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;

  @override
  State<LiquidGlassMenuButton> createState() => LiquidGlassMenuButtonState();
}

class LiquidGlassMenuButtonState extends State<LiquidGlassMenuButton> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassPlatform.menuButtonChannelPrefix}/$viewId',
      );
  String? lastNativeValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncConfiguration();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.value != widget.value && widget.value != lastNativeValue;
      final configurationChange =
          oldWidget.title != widget.title ||
          oldWidget.options != widget.options ||
          oldWidget.enabled != widget.enabled ||
          oldWidget.tintColor != widget.tintColor ||
          oldWidget.nativePolicy != widget.nativePolicy;

      if (externalValueChange || configurationChange) {
        syncConfiguration(force: true);
      }
    } else {
      clearChannel();
    }
  }

  @override
  void dispose() {
    clearChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (usesNativeView) {
      return SizedBox(
        height: widget.height,
        child: UiKitView(
          viewType: LiquidGlassPlatform.menuButtonViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    final selected = selectedOption;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: widget.enabled,
      title: Text(widget.title),
      subtitle: selected == null ? null : Text(selected.title),
      trailing: const Icon(Icons.keyboard_arrow_down_rounded),
      onTap: widget.enabled ? showFallbackMenu : null,
    );
  }

  LiquidGlassAction? get selectedOption {
    for (final option in widget.options) {
      if (option.value == widget.value) {
        return option;
      }
    }
    return null;
  }

  bool get usesNativeView {
    return LiquidGlassNativeResolver(
      isNativeIOS: widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS,
      policy: widget.nativePolicy,
    ).usesNativeControl;
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);
    final materialTheme = Theme.of(context);

    return <String, Object?>{
      LiquidGlassBridgeKeys.title: widget.title,
      LiquidGlassBridgeKeys.value: widget.value,
      LiquidGlassBridgeKeys.actions: widget.options
          .map((action) => action.toPlatformMap())
          .toList(),
      LiquidGlassBridgeKeys.enabled: widget.enabled,
      LiquidGlassBridgeKeys.tintColor: (widget.tintColor ?? theme.accentColor)
          .toARGB32(),
      LiquidGlassBridgeKeys.isDark: materialTheme.brightness == Brightness.dark,
      LiquidGlassBridgeKeys.isRtl:
          Directionality.of(context) == TextDirection.rtl,
    };
  }

  void configureChannel(int viewId) {
    channel.attach(viewId, handler: handleMethodCall);
    syncConfiguration(force: true);
  }

  void clearChannel() {
    channel.detach();
    lastNativeValue = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (mounted &&
        call.method == LiquidGlassBridgeMethods.onChanged &&
        call.arguments is String) {
      final value = call.arguments as String;
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }

  Future<void> showFallbackMenu() async {
    final value = await showLiquidGlassOptionPicker(
      context: context,
      title: widget.title,
      message: widget.message,
      options: widget.options,
      cancelTitle: widget.cancelTitle,
      useNativeOnIOS: false,
    );

    if (value != null && mounted) {
      widget.onChanged(value);
    }
  }

  void syncConfiguration({bool force = false}) {
    channel.sync(platformConfiguration(), force: force);
  }
}
