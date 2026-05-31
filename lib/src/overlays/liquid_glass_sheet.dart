import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import 'liquid_glass_sheet_scaffold.dart';

Future<T?> showLiquidGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget? title,
  List<Widget> actions = const <Widget>[],
  LiquidGlassConfiguration? configuration,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool showHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);

      return AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: LiquidGlassSheetScaffold(
          title: title,
          actions: actions,
          configuration: configuration,
          showHandle: showHandle,
          child: builder(sheetContext),
        ),
      );
    },
  );
}
