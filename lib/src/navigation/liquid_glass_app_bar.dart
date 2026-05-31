import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../platform/liquid_glass_native_policy.dart'
    show LiquidGlassSurfaceRole;
import '../platform/liquid_glass_platform.dart';
import '../surfaces/liquid_glass_surface.dart';
import 'liquid_glass_app_bar_action.dart';
import 'liquid_glass_native_app_bar.dart';

class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.center,
    this.leading,
    this.actions = const <Widget>[],
    this.nativeActions = const <LiquidGlassAppBarAction>[],
    this.onNativeActionSelected,
    this.automaticallyImplyLeading = true,
    this.configuration,
    this.height,
    this.padding = const EdgeInsetsDirectional.symmetric(horizontal: 12),
  });

  final Widget? title;
  final Widget? center;
  final Widget? leading;
  final List<Widget> actions;
  final List<LiquidGlassAppBarAction> nativeActions;
  final ValueChanged<String>? onNativeActionSelected;
  final bool automaticallyImplyLeading;
  final LiquidGlassConfiguration? configuration;
  final double? height;
  final EdgeInsetsDirectional padding;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 64);

  @override
  Widget build(BuildContext context) {
    final theme = LiquidGlassTheme.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final nativeTitle = _nativeTitle;

    if (_canUseNativeAppBar(nativeTitle)) {
      return LiquidGlassNativeAppBar(
        title: nativeTitle!,
        canGoBack: automaticallyImplyLeading && canPop,
        onBack: () => Navigator.maybePop(context),
        actions: nativeActions,
        onActionSelected: onNativeActionSelected,
        configuration: configuration,
        height: height,
      );
    }

    final resolvedActions = actions.isNotEmpty
        ? actions
        : nativeActions
              .map((action) => nativeActionFallbackButton(action))
              .toList();
    final resolvedLeading =
        leading ??
        (automaticallyImplyLeading && canPop ? const BackButton() : null);
    final barHeight = height ?? 64;
    final surfaceConfiguration =
        configuration ?? theme.surface.copyWith(cornerRadius: barHeight / 2);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: barHeight,
        child: LiquidGlassSurface(
          height: barHeight,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          padding: padding,
          configuration: surfaceConfiguration.copyWith(
            role: LiquidGlassSurfaceRole.chrome,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (title != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: resolvedLeading == null ? 0 : 52,
                      end: resolvedActions.isEmpty ? 0 : 52,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: theme.foregroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: title!,
                    ),
                  ),
                ),
              if (center != null) Center(child: center),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox.square(dimension: 48, child: resolvedLeading),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: resolvedActions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? get _nativeTitle {
    final title = this.title;
    return title is Text ? title.data : null;
  }

  bool _canUseNativeAppBar(String? nativeTitle) {
    return LiquidGlassPlatform.isNativeIOS &&
        nativeTitle != null &&
        center == null &&
        actions.isEmpty &&
        leading == null;
  }

  Widget nativeActionFallbackButton(LiquidGlassAppBarAction action) {
    final menuActions = action.menuActions;
    if (menuActions.isNotEmpty) {
      return PopupMenuButton<String>(
        tooltip: action.title,
        enabled: action.enabled,
        onSelected: onNativeActionSelected,
        itemBuilder: (context) {
          return menuActions.map((item) {
            return PopupMenuItem<String>(
              value: item.value,
              enabled: item.enabled,
              child: Text(item.title),
            );
          }).toList();
        },
        icon: const Icon(Icons.more_horiz_rounded),
      );
    }

    return IconButton(
      tooltip: action.title,
      onPressed: action.enabled
          ? () => onNativeActionSelected?.call(action.value)
          : null,
      icon: const Icon(Icons.more_horiz_rounded),
    );
  }
}
