import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiquidGlassScaffold extends StatelessWidget {
  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.hideBottomBarWhenKeyboardVisible = true,
    this.bottomBarMargin = const EdgeInsetsDirectional.only(
      start: 16,
      end: 16,
      bottom: 8,
    ),
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool hideBottomBarWhenKeyboardVisible;
  final EdgeInsetsDirectional bottomBarMargin;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final showBottomBar =
        bottomNavigationBar != null &&
        (!keyboardVisible || !hideBottomBarWhenKeyboardVisible);
    final safeBottom = math.max(mediaQuery.padding.bottom, 0);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: body),
          if (showBottomBar)
            PositionedDirectional(
              start: bottomBarMargin.start,
              end: bottomBarMargin.end,
              bottom: bottomBarMargin.bottom + safeBottom,
              child: bottomNavigationBar!,
            ),
        ],
      ),
    );
  }
}
