import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassStepper extends StatefulWidget {
  const LiquidGlassStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.enabled = true,
    this.tintColor,
    this.useNativeOnIOS = true,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;

  @override
  State<LiquidGlassStepper> createState() => LiquidGlassStepperState();
}

class LiquidGlassStepperState extends State<LiquidGlassStepper> {
  MethodChannel? channel;
  double? lastNativeValue;

  @override
  void didUpdateWidget(LiquidGlassStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.value != widget.value && !isNativeEcho(widget.value);
      final configurationChange =
          oldWidget.min != widget.min ||
          oldWidget.max != widget.max ||
          oldWidget.step != widget.step ||
          oldWidget.enabled != widget.enabled ||
          oldWidget.tintColor != widget.tintColor;

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
        width: 100,
        height: 36,
        child: UiKitView(
          viewType: LiquidGlassPlatform.stepperViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: widget.enabled ? () => changeBy(-widget.step) : null,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          onPressed: widget.enabled ? () => changeBy(widget.step) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);

    return <String, Object?>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'step': widget.step,
      'enabled': widget.enabled,
      'tintColor': (widget.tintColor ?? theme.accentColor).toARGB32(),
    };
  }

  bool get usesNativeView {
    return widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS;
  }

  void configureChannel(int viewId) {
    clearChannel();
    channel = MethodChannel('native_liquid_glass_flutter/stepper_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  void clearChannel() {
    channel?.setMethodCallHandler(null);
    channel = null;
    lastNativeValue = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    final value = (call.arguments as num?)?.toDouble();
    if (mounted && call.method == 'onChanged' && value != null) {
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }

  void changeBy(double delta) {
    widget.onChanged((widget.value + delta).clamp(widget.min, widget.max));
  }

  bool isNativeEcho(double value) {
    final nativeValue = lastNativeValue;
    if (nativeValue == null) {
      return false;
    }

    return (nativeValue - value).abs() < 0.000001;
  }
}
