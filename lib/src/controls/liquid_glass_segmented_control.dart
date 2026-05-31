import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_gestures.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassSegment {
  const LiquidGlassSegment({required this.label, this.semanticLabel});

  final String label;
  final String? semanticLabel;
}

class LiquidGlassSegmentedControl extends StatefulWidget {
  const LiquidGlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 40,
    this.enabled = true,
    this.tintColor,
    this.useNativeOnIOS = true,
    this.nativePolicy = LiquidGlassNativePolicy.automatic,
  });

  final List<LiquidGlassSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;
  final LiquidGlassNativePolicy nativePolicy;

  @override
  State<LiquidGlassSegmentedControl> createState() {
    return LiquidGlassSegmentedControlState();
  }
}

class LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassBridgeChannels.segmentedChannelPrefix}_$viewId',
      );
  int? lastNativeValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (usesNativeView) {
      syncConfiguration();
    }
  }

  @override
  void didUpdateWidget(LiquidGlassSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      final externalValueChange =
          oldWidget.selectedIndex != widget.selectedIndex &&
          widget.selectedIndex != lastNativeValue;
      final configurationChange =
          oldWidget.segments != widget.segments ||
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
          viewType: LiquidGlassPlatform.segmentedControlViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: liquidGlassNativeControlGestureRecognizers,
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: List<ButtonSegment<int>>.generate(widget.segments.length, (
        index,
      ) {
        final segment = widget.segments[index];

        return ButtonSegment<int>(
          value: index,
          label: Text(segment.label),
          tooltip: segment.semanticLabel,
        );
      }),
      selected: <int>{widget.selectedIndex},
      onSelectionChanged: widget.enabled
          ? (selection) => widget.onChanged(selection.first)
          : null,
    );
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);

    return <String, Object?>{
      LiquidGlassBridgeKeys.segments: widget.segments
          .map((segment) => segment.label)
          .toList(),
      LiquidGlassBridgeKeys.selectedIndex: widget.selectedIndex,
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
    if (mounted &&
        call.method == LiquidGlassBridgeMethods.onChanged &&
        call.arguments is int) {
      final value = call.arguments as int;
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }
}
