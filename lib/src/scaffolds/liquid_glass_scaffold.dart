import 'package:flutter/material.dart';

import '../config/liquid_glass_theme.dart';
import '../navigation/liquid_glass_tab_bar.dart';
import '../platform/liquid_glass_platform.dart';

class LiquidGlassScaffold extends StatelessWidget {
  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.hideBottomBarWhenKeyboardVisible = true,
    this.bottomBarMargin = EdgeInsetsDirectional.zero,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool hideBottomBarWhenKeyboardVisible;
  final EdgeInsetsDirectional bottomBarMargin;

  static double scrollBottomPadding(BuildContext context, {double base = 0}) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<
          _LiquidGlassScaffoldNavigationScope
        >();
    return base + (scope?.bottomScrollInset ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final showBottomBar =
        bottomNavigationBar != null &&
        (!keyboardVisible || !hideBottomBarWhenKeyboardVisible);
    final bottomScrollInset = showBottomBar
        ? _bottomNavigationScrollInset(context)
        : 0.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _LiquidGlassScaffoldNavigationScope(
              bottomScrollInset: bottomScrollInset,
              child: body,
            ),
          ),
          if (showBottomBar)
            PositionedDirectional(
              start: bottomBarMargin.start,
              end: bottomBarMargin.end,
              bottom: bottomBarMargin.bottom,
              child: bottomNavigationBar!,
            ),
        ],
      ),
    );
  }

  double _bottomNavigationScrollInset(BuildContext context) {
    final bottomNavigationBar = this.bottomNavigationBar;
    if (bottomNavigationBar is LiquidGlassTabBar) {
      return bottomNavigationBar.overlayScrollInset(context);
    }

    final theme = LiquidGlassTheme.of(context);
    if (LiquidGlassPlatform.isNativeIOS) {
      return LiquidGlassTabBar.nativeContentHeight;
    }

    return theme.tabBarHeight + MediaQuery.viewPaddingOf(context).bottom;
  }
}

class _LiquidGlassScaffoldNavigationScope extends InheritedWidget {
  const _LiquidGlassScaffoldNavigationScope({
    required this.bottomScrollInset,
    required super.child,
  });

  final double bottomScrollInset;

  @override
  bool updateShouldNotify(_LiquidGlassScaffoldNavigationScope oldWidget) {
    return bottomScrollInset != oldWidget.bottomScrollInset;
  }
}
