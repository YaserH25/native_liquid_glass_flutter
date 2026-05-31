import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_bridge_keys.dart';
import '../platform/liquid_glass_native_view_channel.dart';
import '../platform/liquid_glass_native_policy.dart';
import '../platform/liquid_glass_platform.dart';
import '../surfaces/liquid_glass_surface.dart';
import 'liquid_glass_tab_item.dart';

final Set<Factory<OneSequenceGestureRecognizer>> _nativeTabBarGestures =
    Set<Factory<OneSequenceGestureRecognizer>>.unmodifiable(
      <Factory<OneSequenceGestureRecognizer>>[
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      ],
    );

class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.configuration,
    this.height,
    this.iconTextGap = 6,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  static const double nativeContentHeight = 52;

  final List<LiquidGlassTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final LiquidGlassConfiguration? configuration;
  final double? height;
  final double iconTextGap;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsetsGeometry margin;

  double overlayScrollInset(BuildContext context) {
    if (usesNativeView(context)) {
      return (height ?? nativeContentHeight) +
          MediaQuery.viewPaddingOf(context).bottom;
    }

    final theme = LiquidGlassTheme.of(context);
    final resolvedMargin = margin.resolve(Directionality.of(context));
    return (height ?? theme.tabBarHeight) +
        MediaQuery.viewPaddingOf(context).bottom +
        resolvedMargin.vertical;
  }

  bool usesNativeView(BuildContext context) {
    if (!items.every((item) => item.isNativeRepresentable)) {
      return false;
    }

    final theme = LiquidGlassTheme.of(context);
    final tabHeight = height ?? theme.tabBarHeight;
    final configuration = resolvedConfiguration(theme, tabHeight);

    return LiquidGlassNativeResolver(
      isNativeIOS: LiquidGlassPlatform.isNativeIOS,
      policy: configuration.resolvedNativePolicy,
      role: configuration.role,
    ).usesNativeSurface;
  }

  LiquidGlassConfiguration resolvedConfiguration(
    LiquidGlassThemeData theme,
    double tabHeight,
  ) {
    final surfaceConfiguration =
        configuration ??
        theme.surface.copyWith(cornerRadius: tabHeight / 2, interactive: true);

    return surfaceConfiguration.copyWith(role: LiquidGlassSurfaceRole.chrome);
  }

  @override
  State<LiquidGlassTabBar> createState() => LiquidGlassTabBarState();
}

class LiquidGlassTabBarState extends State<LiquidGlassTabBar> {
  late final LiquidGlassNativeViewChannel channel =
      LiquidGlassNativeViewChannel(
        nameForViewId: (viewId) =>
            '${LiquidGlassPlatform.tabBarChannelPrefix}/$viewId',
      );
  int? lastSyncedSelectedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncConfiguration();
    syncSelectedIndex();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (usesNativeView) {
      syncConfiguration();
      if (oldWidget.selectedIndex != widget.selectedIndex) {
        syncSelectedIndex(force: true);
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
    final theme = LiquidGlassTheme.of(context);
    final tabHeight = widget.height ?? theme.tabBarHeight;
    final surfaceConfiguration = widget.resolvedConfiguration(theme, tabHeight);

    if (usesNativeView) {
      return SizedBox(
        height:
            (widget.height ?? LiquidGlassTabBar.nativeContentHeight) +
            MediaQuery.viewPaddingOf(context).bottom,
        child: UiKitView(
          viewType: LiquidGlassPlatform.tabBarViewType,
          creationParams: platformConfiguration(),
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: _nativeTabBarGestures,
          onPlatformViewCreated: configureChannel,
        ),
      );
    }

    return SafeArea(
      top: false,
      minimum: widget.margin.resolve(Directionality.of(context)),
      child: LiquidGlassSurface(
        height: tabHeight,
        padding: const EdgeInsets.all(6),
        configuration: surfaceConfiguration,
        child: Row(
          children: List<Widget>.generate(widget.items.length, (index) {
            return Expanded(
              child: LiquidGlassTabButton(
                item: widget.items[index],
                selected: widget.selectedIndex == index,
                onTap: () => widget.onSelected(index),
                iconTextGap: widget.iconTextGap,
                padding: widget.itemPadding,
              ),
            );
          }),
        ),
      ),
    );
  }

  bool get usesNativeView {
    return widget.usesNativeView(context);
  }

  void configureChannel(int viewId) {
    channel.attach(viewId, handler: handleMethodCall);
    syncConfiguration(force: true);
  }

  void clearChannel() {
    channel.detach();
    lastSyncedSelectedIndex = null;
  }

  Future<void> handleMethodCall(MethodCall call) async {
    if (!mounted) {
      return;
    }

    if (call.method != LiquidGlassBridgeMethods.onTap) {
      return;
    }

    final index = call.arguments;
    if (index is int && index != widget.selectedIndex) {
      widget.onSelected(index);
    }
  }

  void syncConfiguration({bool force = false}) {
    if (!channel.isAttached) {
      return;
    }

    final configuration = platformConfiguration();
    if (force) {
      lastSyncedSelectedIndex = widget.selectedIndex;
    }
    channel.sync(
      configuration,
      force: force,
      signature: configurationSignature(configuration),
    );
  }

  void syncSelectedIndex({bool force = false}) {
    if (!channel.isAttached) {
      return;
    }

    final selectedIndex = widget.selectedIndex;
    if (!force && lastSyncedSelectedIndex == selectedIndex) {
      return;
    }

    lastSyncedSelectedIndex = selectedIndex;
    channel.invoke(LiquidGlassBridgeMethods.setSelectedIndex, <String, Object>{
      LiquidGlassBridgeKeys.index: selectedIndex,
    });
  }

  Map<String, Object> platformConfiguration() {
    final theme = LiquidGlassTheme.of(context);
    final materialTheme = Theme.of(context);
    final tabHeight = widget.height ?? theme.tabBarHeight;
    final surfaceConfiguration = widget.resolvedConfiguration(theme, tabHeight);

    return <String, Object>{
      LiquidGlassBridgeKeys.items: widget.items
          .map((item) => item.toPlatformMap())
          .toList(),
      LiquidGlassBridgeKeys.selectedIndex: widget.selectedIndex,
      LiquidGlassBridgeKeys.selectedColor: theme.accentColor.toARGB32(),
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

  String configurationSignature(Map<String, Object> configuration) {
    final stableConfiguration = Map<String, Object>.of(configuration)
      ..remove(LiquidGlassBridgeKeys.selectedIndex);
    return stableConfiguration.toString();
  }
}

class LiquidGlassTabButton extends StatelessWidget {
  const LiquidGlassTabButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    required this.iconTextGap,
    required this.padding,
  });

  final LiquidGlassTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double iconTextGap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final color = selected
        ? theme.selectedForegroundColor
        : theme.foregroundColor;

    return Semantics(
      selected: selected,
      label: item.semanticLabel,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: padding,
          decoration: ShapeDecoration(
            color: selected
                ? theme.accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: color, size: 27),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                height: 1.05,
              ),
              textAlign: TextAlign.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  selected ? item.selectedIcon ?? item.icon : item.icon,
                  SizedBox(height: iconTextGap),
                  item.label,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
