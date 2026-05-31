import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.enabled = true,
    this.useNativeOnIOS = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final bool enabled;
  final bool useNativeOnIOS;

  @override
  State<LiquidGlassSwitch> createState() => LiquidGlassSwitchState();
}

class LiquidGlassSwitchState extends State<LiquidGlassSwitch> {
  MethodChannel? channel;
  bool? lastNativeValue;

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.value != widget.value && widget.value != lastNativeValue;
      final configurationChange =
          oldWidget.enabled != widget.enabled ||
          oldWidget.activeColor != widget.activeColor;

      if (externalValueChange || configurationChange) {
        channel?.invokeMethod<void>(
          'setConfiguration',
          platformConfiguration(),
        );
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
        width: 58,
        height: 36,
        child: UiKitView(
          viewType: LiquidGlassPlatform.switchViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    return Switch(
      value: widget.value,
      activeThumbColor: widget.activeColor,
      onChanged: widget.enabled ? widget.onChanged : null,
    );
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);

    return <String, Object?>{
      'value': widget.value,
      'enabled': widget.enabled,
      'activeColor': (widget.activeColor ?? theme.accentColor).toARGB32(),
    };
  }

  bool get usesNativeView {
    return widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS;
  }

  void configureChannel(int viewId) {
    clearChannel();
    channel = MethodChannel('native_liquid_glass_flutter/switch_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  void clearChannel() {
    channel?.setMethodCallHandler(null);
    channel = null;
    lastNativeValue = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (mounted && call.method == 'onChanged' && call.arguments is bool) {
      final value = call.arguments as bool;
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }
}
