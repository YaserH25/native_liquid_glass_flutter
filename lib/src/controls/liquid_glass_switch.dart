import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.enabled = true,
    this.useNativeOnIOS = true,
    this.nativePolicy = LiquidGlassNativePolicy.automatic,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final bool enabled;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;

  @override
  State<LiquidGlassSwitch> createState() => LiquidGlassSwitchState();
}

class LiquidGlassSwitchState extends State<LiquidGlassSwitch> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassBridgeChannels.switchChannelPrefix}_$viewId',
      );
  bool? lastNativeValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (usesNativeView) {
      syncConfiguration();
    }
  }

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.value != widget.value && widget.value != lastNativeValue;
      final configurationChange =
          oldWidget.enabled != widget.enabled ||
          oldWidget.activeColor != widget.activeColor ||
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
        width: 58,
        height: 36,
        child: UiKitView(
          viewType: LiquidGlassPlatform.switchViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
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
      LiquidGlassBridgeKeys.value: widget.value,
      LiquidGlassBridgeKeys.enabled: widget.enabled,
      LiquidGlassBridgeKeys.activeColor:
          (widget.activeColor ?? theme.accentColor).toARGB32(),
    };
  }

  bool get usesNativeView {
    return LiquidGlassNativeResolver(
      isNativeIOS: widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS,
      policy: widget.nativePolicy,
    ).usesNativeControl;
  }

  void configureChannel(int viewId) {
    channel.attach(viewId, handler: handleMethodCall);
    syncConfiguration(force: true);
  }

  void clearChannel() {
    channel.detach();
    lastNativeValue = null;
  }

  void syncConfiguration({bool force = false}) {
    channel.sync(platformConfiguration(), force: force);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (mounted &&
        call.method == LiquidGlassBridgeMethods.onChanged &&
        call.arguments is bool) {
      final value = call.arguments as bool;
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }
}
