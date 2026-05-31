import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.configuration,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.constraints,
    this.alignment = Alignment.center,
    this.useNativeOnIOS = true,
  });

  final Widget child;
  final LiquidGlassConfiguration? configuration;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry alignment;
  final bool useNativeOnIOS;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final resolvedConfiguration = configuration ?? theme.surface;
    final radius = _borderRadiusFor(resolvedConfiguration);
    final showNative = LiquidGlassNativeResolver(
      isNativeIOS: useNativeOnIOS && LiquidGlassPlatform.isNativeIOS,
      policy: resolvedConfiguration.resolvedNativePolicy,
      role: resolvedConfiguration.role,
    ).usesNativeSurface;

    return Padding(
      padding: margin,
      child: ConstrainedBox(
        constraints: constraints ?? const BoxConstraints(),
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRSuperellipse(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                Positioned.fill(
                  child: LiquidGlassSurfaceBackdrop(
                    configuration: resolvedConfiguration,
                    fallbackColor: theme.fallbackSurfaceColor,
                    borderRadius: radius,
                    useNative: showNative,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: RoundedSuperellipseBorder(
                        borderRadius: radius,
                        side: BorderSide(
                          color: theme.foregroundColor.withValues(
                            alpha: resolvedConfiguration.strokeOpacity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: Align(
                    alignment: alignment,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderRadiusGeometry _borderRadiusFor(
    LiquidGlassConfiguration configuration,
  ) {
    final cornerRadius = Radius.circular(configuration.cornerRadius);

    return switch (configuration.cornerStyle) {
      LiquidGlassCornerStyle.all => BorderRadius.all(cornerRadius),
      LiquidGlassCornerStyle.top => BorderRadius.vertical(top: cornerRadius),
      LiquidGlassCornerStyle.none => BorderRadius.zero,
    };
  }
}

class LiquidGlassSurfaceBackdrop extends StatefulWidget {
  const LiquidGlassSurfaceBackdrop({
    super.key,
    required this.configuration,
    required this.fallbackColor,
    required this.borderRadius,
    required this.useNative,
  });

  final LiquidGlassConfiguration configuration;
  final Color fallbackColor;
  final BorderRadiusGeometry borderRadius;
  final bool useNative;

  @override
  State<LiquidGlassSurfaceBackdrop> createState() {
    return LiquidGlassSurfaceBackdropState();
  }
}

class LiquidGlassSurfaceBackdropState
    extends State<LiquidGlassSurfaceBackdrop> {
  MethodChannel? channel;
  Map<String, Object?>? lastPlatformConfiguration;

  @override
  void didUpdateWidget(LiquidGlassSurfaceBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useNative) {
      syncNativeConfiguration();
    } else {
      clearChannel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.useNative) {
      syncNativeConfiguration();
    }
  }

  @override
  void dispose() {
    clearChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNative) {
      return UiKitView(
        viewType: LiquidGlassPlatform.surfaceViewType,
        creationParams: platformConfiguration(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: configureChannel,
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.configuration.blurSigma,
        sigmaY: widget.configuration.blurSigma,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _fallbackColor(),
          borderRadius: widget.borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: widget.configuration.shadowOpacity,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
      ),
    );
  }

  void configureChannel(int viewId) {
    clearChannel();
    channel = MethodChannel(
      '${LiquidGlassBridgeChannels.surfaceChannelPrefix}_$viewId',
    );
    syncNativeConfiguration();
  }

  void syncNativeConfiguration() {
    final configuration = platformConfiguration();
    if (mapEquals(lastPlatformConfiguration, configuration)) {
      return;
    }

    lastPlatformConfiguration = configuration;
    channel?.invokeMethod<void>(
      LiquidGlassBridgeMethods.setConfiguration,
      configuration,
    );
  }

  void clearChannel() {
    channel = null;
    lastPlatformConfiguration = null;
  }

  Map<String, Object?> platformConfiguration() {
    return <String, Object?>{
      ...widget.configuration.toPlatformMap(),
      LiquidGlassBridgeKeys.isDark:
          Theme.of(context).brightness == Brightness.dark,
    };
  }

  Color _fallbackColor() {
    return (widget.configuration.tintColor ?? widget.fallbackColor).withValues(
      alpha: widget.configuration.tintOpacity,
    );
  }
}
