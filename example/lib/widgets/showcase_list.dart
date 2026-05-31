import 'package:flutter/material.dart';

class ShowcaseList extends StatelessWidget {
  const ShowcaseList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 116),
      children: children,
    );
  }
}
