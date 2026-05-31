import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassSlider extends StatefulWidget {
  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.step,
    this.height = 48,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
    this.useNativeOnIOS = true,
    this.nativePolicy = LiquidGlassNativePolicy.automatic,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final double? step;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enabled;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;

  @override
  State<LiquidGlassSlider> createState() => LiquidGlassSliderState();
}

class LiquidGlassSliderState extends State<LiquidGlassSlider> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassBridgeChannels.sliderChannelPrefix}_$viewId',
      );
  double? lastNativeValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (usesNativeView) {
      syncConfiguration();
    }
  }

  @override
  void didUpdateWidget(LiquidGlassSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.value != widget.value && !isNativeEcho(widget.value);
      final configurationChange =
          oldWidget.min != widget.min ||
          oldWidget.max != widget.max ||
          oldWidget.step != widget.step ||
          oldWidget.enabled != widget.enabled ||
          oldWidget.activeColor != widget.activeColor ||
          oldWidget.inactiveColor != widget.inactiveColor ||
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
          viewType: LiquidGlassPlatform.sliderViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    return Slider(
      value: widget.value.clamp(widget.min, widget.max).toDouble(),
      min: widget.min,
      max: widget.max,
      divisions: divisions,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      onChanged: widget.enabled ? widget.onChanged : null,
      onChangeEnd: widget.enabled ? widget.onChangeEnd : null,
    );
  }

  int? get divisions {
    final step = widget.step;
    if (step == null || step <= 0) {
      return null;
    }

    final divisionCount = ((widget.max - widget.min) / step).round();
    return divisionCount < 1 ? 1 : divisionCount;
  }

  bool get usesNativeView {
    return LiquidGlassNativeResolver(
      isNativeIOS: widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS,
      policy: widget.nativePolicy,
    ).usesNativeControl;
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);

    return <String, Object?>{
      LiquidGlassBridgeKeys.value: widget.value,
      LiquidGlassBridgeKeys.min: widget.min,
      LiquidGlassBridgeKeys.max: widget.max,
      LiquidGlassBridgeKeys.step: widget.step,
      LiquidGlassBridgeKeys.enabled: widget.enabled,
      LiquidGlassBridgeKeys.activeColor:
          (widget.activeColor ?? theme.accentColor).toARGB32(),
      LiquidGlassBridgeKeys.inactiveColor: widget.inactiveColor?.toARGB32(),
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

  void syncConfiguration({bool force = false}) {
    channel.sync(platformConfiguration(), force: force);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    final value = (call.arguments as num?)?.toDouble();
    if (value == null) {
      return;
    }

    switch (call.method) {
      case LiquidGlassBridgeMethods.onChanged:
        if (mounted) {
          lastNativeValue = value;
          widget.onChanged(value);
        }
      case LiquidGlassBridgeMethods.onChangeEnd:
        if (mounted) {
          lastNativeValue = value;
          widget.onChangeEnd?.call(value);
        }
    }
  }

  bool isNativeEcho(double value) {
    final nativeValue = lastNativeValue;
    if (nativeValue == null) {
      return false;
    }

    return (nativeValue - value).abs() < 0.000001;
  }
}
