import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_native_view_channel.dart';
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
    this.nativePolicy = LiquidGlassNativePolicy.automatic,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;

  @override
  State<LiquidGlassStepper> createState() => LiquidGlassStepperState();
}

class LiquidGlassStepperState extends State<LiquidGlassStepper> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassBridgeChannels.stepperChannelPrefix}_$viewId',
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
        width: 100,
        height: 36,
        child: UiKitView(
          viewType: LiquidGlassPlatform.stepperViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
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
      LiquidGlassBridgeKeys.value: widget.value,
      LiquidGlassBridgeKeys.min: widget.min,
      LiquidGlassBridgeKeys.max: widget.max,
      LiquidGlassBridgeKeys.step: widget.step,
      LiquidGlassBridgeKeys.enabled: widget.enabled,
      LiquidGlassBridgeKeys.tintColor: (widget.tintColor ?? theme.accentColor)
          .toARGB32(),
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
    final value = (call.arguments as num?)?.toDouble();
    if (mounted &&
        call.method == LiquidGlassBridgeMethods.onChanged &&
        value != null) {
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
