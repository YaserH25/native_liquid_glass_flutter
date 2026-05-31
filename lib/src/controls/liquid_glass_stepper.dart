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

  @override
  void didUpdateWidget(LiquidGlassStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.tintColor != widget.tintColor) {
      channel?.invokeMethod<void>('setConfiguration', platformConfiguration());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS) {
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

  void configureChannel(int viewId) {
    channel = MethodChannel('native_liquid_glass_flutter/stepper_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    final value = (call.arguments as num?)?.toDouble();
    if (call.method == 'onChanged' && value != null) {
      widget.onChanged(value);
    }
  }

  void changeBy(double delta) {
    widget.onChanged((widget.value + delta).clamp(widget.min, widget.max));
  }
}
