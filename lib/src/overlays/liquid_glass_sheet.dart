import 'package:flutter/material.dart';

import '../config/liquid_glass_configuration.dart';
import 'liquid_glass_sheet_scaffold.dart';

enum LiquidGlassSheetDetent { content, medium, large }

Future<T?> showLiquidGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget? title,
  List<Widget> actions = const <Widget>[],
  LiquidGlassConfiguration? configuration,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool showHandle = true,
  LiquidGlassSheetDetent detent = LiquidGlassSheetDetent.content,
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
      final sheet = LiquidGlassSheetScaffold(
        title: title,
        actions: actions,
        configuration: configuration,
        showHandle: showHandle,
        child: builder(sheetContext),
      );
      final constrainedSheet = switch (detent) {
        LiquidGlassSheetDetent.content => sheet,
        LiquidGlassSheetDetent.medium => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
          ),
          child: SingleChildScrollView(child: sheet),
        ),
        LiquidGlassSheetDetent.large => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.92,
          ),
          child: SingleChildScrollView(child: sheet),
        ),
      };

      return AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: constrainedSheet,
      );
    },
  );
}
