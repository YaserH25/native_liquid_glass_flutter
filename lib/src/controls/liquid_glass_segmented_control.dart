import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_theme.dart';
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
  });

  final List<LiquidGlassSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final bool enabled;
  final Color? tintColor;
  final bool useNativeOnIOS;

  @override
  State<LiquidGlassSegmentedControl> createState() {
    return LiquidGlassSegmentedControlState();
  }
}

class LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl> {
  MethodChannel? channel;
  int? lastNativeValue;

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
        height: widget.height,
        child: UiKitView(
          viewType: LiquidGlassPlatform.segmentedControlViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
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
      'segments': widget.segments.map((segment) => segment.label).toList(),
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      'tintColor': (widget.tintColor ?? theme.accentColor).toARGB32(),
    };
  }

  bool get usesNativeView {
    return widget.useNativeOnIOS && LiquidGlassPlatform.isNativeIOS;
  }

  void configureChannel(int viewId) {
    clearChannel();
    channel = MethodChannel('native_liquid_glass_flutter/segmented_$viewId');
    channel?.setMethodCallHandler(handleMethodCall);
  }

  void clearChannel() {
    channel?.setMethodCallHandler(null);
    channel = null;
    lastNativeValue = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (mounted && call.method == 'onChanged' && call.arguments is int) {
      final value = call.arguments as int;
      lastNativeValue = value;
      widget.onChanged(value);
    }
  }
}
