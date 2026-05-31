import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_platform.dart';

final Set<Factory<OneSequenceGestureRecognizer>> _nativeNavigationBarGestures =
    Set<Factory<OneSequenceGestureRecognizer>>.unmodifiable(
      <Factory<OneSequenceGestureRecognizer>>[
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      ],
    );

class LiquidGlassNativeAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const LiquidGlassNativeAppBar({
    super.key,
    required this.title,
    required this.canGoBack,
    this.onBack,
    this.configuration,
    this.height,
  });

  final String title;
  final bool canGoBack;
  final VoidCallback? onBack;
  final LiquidGlassConfiguration? configuration;
  final double? height;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 64);

  @override
  State<LiquidGlassNativeAppBar> createState() =>
      LiquidGlassNativeAppBarState();
}

class LiquidGlassNativeAppBarState extends State<LiquidGlassNativeAppBar> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassPlatform.navigationBarChannelPrefix}/$viewId',
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncConfiguration();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNativeAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfiguration();
  }

  @override
  void dispose() {
    channel.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = widget.height ?? 64;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: barHeight,
        child: UiKitView(
          viewType: LiquidGlassPlatform.navigationBarViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: _nativeNavigationBarGestures,
          onPlatformViewCreated: configureChannel,
        ),
      ),
    );
  }

  void configureChannel(int viewId) {
    channel.attach(viewId, handler: handleMethodCall);
    syncConfiguration(force: true);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (!mounted || call.method != LiquidGlassBridgeMethods.onBack) {
      return;
    }

    widget.onBack?.call();
  }

  void syncConfiguration({bool force = false}) {
    final configuration = platformConfiguration();
    channel.sync(
      configuration,
      force: force,
      signature: configuration.toString(),
    );
  }

  Map<String, Object?> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);
    final materialTheme = Theme.of(context);
    final barHeight = widget.height ?? 64;
    final surfaceConfiguration =
        widget.configuration ??
        theme.surface.copyWith(cornerRadius: barHeight / 2);

    return <String, Object?>{
      LiquidGlassBridgeKeys.title: widget.title,
      LiquidGlassBridgeKeys.canGoBack: widget.canGoBack,
      LiquidGlassBridgeKeys.foregroundColor: theme.foregroundColor.toARGB32(),
      LiquidGlassBridgeKeys.backgroundColor:
          (surfaceConfiguration.tintColor ?? materialTheme.colorScheme.surface)
              .toARGB32(),
      LiquidGlassBridgeKeys.isRtl:
          Directionality.of(context) == TextDirection.rtl,
      LiquidGlassBridgeKeys.isDark: materialTheme.brightness == Brightness.dark,
      LiquidGlassBridgeKeys.locale: Localizations.localeOf(
        context,
      ).toLanguageTag(),
    };
  }
}
