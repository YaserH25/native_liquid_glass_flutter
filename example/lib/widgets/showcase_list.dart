import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

class ShowcaseList extends StatelessWidget {
  const ShowcaseList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        LiquidGlassScaffold.scrollBottomPadding(context, base: 24),
      ),
      children: children,
    );
  }
}
