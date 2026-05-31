import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';

class UiMenuShowcase extends StatefulWidget {
  const UiMenuShowcase({super.key, this.onSelectionChanged});

  final ValueChanged<String>? onSelectionChanged;

  @override
  State<UiMenuShowcase> createState() => UiMenuShowcaseState();
}

class UiMenuShowcaseState extends State<UiMenuShowcase> {
  String selectedValue = 'comfortable';
  String lastPullDownCommand = 'None';
  String lastIconCommand = 'None';
  double sliderValue = 0.56;

  static const List<LiquidGlassAction> densityOptions = <LiquidGlassAction>[
    LiquidGlassAction(title: 'Compact', value: 'compact'),
    LiquidGlassAction(
      title: 'Comfortable',
      value: 'comfortable',
      role: LiquidGlassActionRole.preferred,
    ),
    LiquidGlassAction(title: 'Spacious', value: 'spacious'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExampleSection(
          title: 'Native UIMenu',
          subtitle: 'Full-width settings row.',
          children: <Widget>[
            Text('Selected: ${selectedTitleFor(selectedValue)}'),
            const SizedBox(height: 10),
            LiquidGlassMenuButton(
              title: 'Density',
              value: selectedValue,
              nativePolicy: LiquidGlassNativePolicy.native,
              onChanged: selectValue,
              options: densityOptions,
            ),
          ],
        ),
        ExampleSection(
          title: 'Pull-down button',
          subtitle: 'Compact command button.',
          children: <Widget>[
            Text('Last command: $lastPullDownCommand'),
            const SizedBox(height: 10),
            LiquidGlassPullDownButton(
              title: 'More',
              width: 128,
              nativePolicy: LiquidGlassNativePolicy.native,
              onSelected: selectPullDownCommand,
              actions: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                LiquidGlassAction(title: 'Archive', value: 'archive'),
                LiquidGlassAction(
                  title: 'Delete',
                  value: 'delete',
                  role: LiquidGlassActionRole.destructive,
                ),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Action menu button',
          subtitle: 'Icon-only toolbar action.',
          children: <Widget>[
            Text('Last icon action: $lastIconCommand'),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: LiquidGlassPullDownButton(
                title: 'Actions',
                icon: const Icon(Icons.more_horiz_rounded),
                nativeSymbol: 'ellipsis.circle',
                showTitle: false,
                nativePolicy: LiquidGlassNativePolicy.native,
                onSelected: selectIconCommand,
                actions: const <LiquidGlassAction>[
                  LiquidGlassAction(title: 'Duplicate', value: 'duplicate'),
                  LiquidGlassAction(title: 'Archive', value: 'archive'),
                  LiquidGlassAction(
                    title: 'Delete',
                    value: 'delete',
                    role: LiquidGlassActionRole.destructive,
                  ),
                ],
              ),
            ),
          ],
        ),
        ExampleSection(
          title: 'Pull-down slider',
          subtitle: 'A command opens a sheet with the native iOS slider.',
          children: <Widget>[
            Text('Intensity: ${(sliderValue * 100).round()}%'),
            const SizedBox(height: 10),
            LiquidGlassPullDownButton(
              title: 'Adjust',
              width: 140,
              nativePolicy: LiquidGlassNativePolicy.native,
              onSelected: selectSliderCommand,
              actions: const <LiquidGlassAction>[
                LiquidGlassAction(
                  title: 'Adjust intensity',
                  value: 'adjust',
                  role: LiquidGlassActionRole.preferred,
                ),
                LiquidGlassAction(title: 'Reset', value: 'reset'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void selectValue(String value) {
    setState(() => selectedValue = value);
    widget.onSelectionChanged?.call('UIMenu: ${selectedTitleFor(value)}');
  }

  void selectPullDownCommand(String value) {
    final title = titleForPullDownCommand(value);
    setState(() => lastPullDownCommand = title);
    widget.onSelectionChanged?.call('Pull-down: $title');
  }

  void selectIconCommand(String value) {
    final title = titleForPullDownCommand(value);
    setState(() => lastIconCommand = title);
    widget.onSelectionChanged?.call('Action menu: $title');
  }

  Future<void> selectSliderCommand(String value) async {
    switch (value) {
      case 'adjust':
        await showLiquidGlassSheet<void>(
          context: context,
          title: const Text('Adjust intensity'),
          builder: (context) {
            return PullDownSliderSheetContent(
              initialValue: sliderValue,
              onChanged: updateSliderValue,
            );
          },
        );
        return;
      case 'reset':
        updateSliderValue(0.56);
    }
  }

  void updateSliderValue(double value) {
    if (!mounted) {
      return;
    }

    setState(() => sliderValue = value);
    widget.onSelectionChanged?.call('Slider: ${(value * 100).round()}%');
  }

  String selectedTitleFor(String value) {
    for (final option in densityOptions) {
      if (option.value == value) {
        return option.title;
      }
    }
    return value;
  }

  String titleForPullDownCommand(String value) {
    switch (value) {
      case 'duplicate':
        return 'Duplicate';
      case 'archive':
        return 'Archive';
      case 'delete':
        return 'Delete';
    }
    return value;
  }
}

class PullDownSliderSheetContent extends StatefulWidget {
  const PullDownSliderSheetContent({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  State<PullDownSliderSheetContent> createState() {
    return PullDownSliderSheetContentState();
  }
}

class PullDownSliderSheetContentState
    extends State<PullDownSliderSheetContent> {
  late double value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Intensity: ${(value * 100).round()}%'),
        const SizedBox(height: 16),
        LiquidGlassSlider(
          value: value,
          nativePolicy: LiquidGlassNativePolicy.native,
          onChanged: updateValue,
          onChangeEnd: updateValue,
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          prominent: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  void updateValue(double nextValue) {
    setState(() => value = nextValue);
    widget.onChanged(nextValue);
  }
}
