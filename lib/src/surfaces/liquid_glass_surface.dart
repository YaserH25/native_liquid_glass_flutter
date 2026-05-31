import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
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
    final radius = BorderRadius.circular(resolvedConfiguration.cornerRadius);
    final showNative =
        useNativeOnIOS &&
        resolvedConfiguration.preferNative &&
        LiquidGlassPlatform.isNativeIOS;

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
}

class LiquidGlassSurfaceBackdrop extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (useNative) {
      return UiKitView(
        viewType: LiquidGlassPlatform.surfaceViewType,
        creationParams: configuration.toPlatformMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: configuration.blurSigma,
        sigmaY: configuration.blurSigma,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _fallbackColor(),
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: configuration.shadowOpacity,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _fallbackColor() {
    return (configuration.tintColor ?? fallbackColor).withValues(
      alpha: configuration.tintOpacity,
    );
  }
}
