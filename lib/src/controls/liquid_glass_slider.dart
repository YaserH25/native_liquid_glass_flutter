import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
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

  @override
  State<LiquidGlassSlider> createState() => LiquidGlassSliderState();
}

class LiquidGlassSliderState extends State<LiquidGlassSlider> {
  MethodChannel? channel;
  double? lastNativeValue;

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
          oldWidget.inactiveColor != widget.inactiveColor;

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
        height: widget.height,
        child: UiKitView(
          viewType: LiquidGlassPlatform.sliderViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
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
    return widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS;
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);

    return <String, Object?>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'step': widget.step,
      'enabled': widget.enabled,
      'activeColor': (widget.activeColor ?? theme.accentColor).toARGB32(),
      'inactiveColor': widget.inactiveColor?.toARGB32(),
    };
  }

  void configureChannel(int viewId) {
    clearChannel();
    channel = MethodChannel('native_liquid_glass_flutter/slider_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  void clearChannel() {
    channel?.setMethodCallHandler(null);
    channel = null;
    lastNativeValue = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    final value = (call.arguments as num?)?.toDouble();
    if (value == null) {
      return;
    }

    switch (call.method) {
      case 'onChanged':
        if (mounted) {
          lastNativeValue = value;
          widget.onChanged(value);
        }
      case 'onChangeEnd':
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
