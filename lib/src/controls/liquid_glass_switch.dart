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

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.activeColor != widget.activeColor) {
      channel?.invokeMethod<void>('setConfiguration', platformConfiguration());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
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

  void configureChannel(int viewId) {
    channel = MethodChannel('native_liquid_glass_flutter/switch_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is bool) {
      widget.onChanged(call.arguments as bool);
    }
  }
}
