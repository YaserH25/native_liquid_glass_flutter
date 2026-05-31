import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import '../config/liquid_glass_theme.dart';
import '../surfaces/liquid_glass_surface.dart';

class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.center,
    this.leading,
    this.actions = const <Widget>[],
    this.automaticallyImplyLeading = true,
    this.configuration,
    this.height,
    this.padding = const EdgeInsetsDirectional.symmetric(horizontal: 12),
  });

  final Widget? title;
  final Widget? center;
  final Widget? leading;
  final List<Widget> actions;
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
    final resolvedLeading =
        leading ??
        (automaticallyImplyLeading && canPop ? const BackButton() : null);
    final barHeight = height ?? theme.appBarHeight;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: barHeight,
        child: LiquidGlassSurface(
          height: barHeight,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          padding: padding,
          configuration:
              configuration ??
              theme.surface.copyWith(cornerRadius: barHeight / 2),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (title != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: resolvedLeading == null ? 0 : 52,
                      end: actions.isEmpty ? 0 : 52,
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
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
