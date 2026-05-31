import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';
import 'showcase_list.dart';

class OverlayShowcase extends StatefulWidget {
  const OverlayShowcase({super.key});

  @override
  State<OverlayShowcase> createState() => OverlayShowcaseState();
}

class OverlayShowcaseState extends State<OverlayShowcase> {
  String selectedOption = 'regular';
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 30);
  DateTime selectedDate = DateTime(2026, 5, 31);

  @override
  Widget build(BuildContext context) {
    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Native action sheet and alert',
          children: <Widget>[
            LiquidGlassButton(
              prominent: true,
              onPressed: showActionSheet,
              child: const Text('Show action sheet'),
            ),
            const SizedBox(height: 12),
            LiquidGlassButton(
              onPressed: showAlert,
              child: const Text('Show alert'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native dropdown style picker',
          children: <Widget>[
            LiquidGlassPickerButton(
              title: 'Glass intensity',
              value: selectedOption,
              onChanged: (value) => setState(() => selectedOption = value),
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Subtle', value: 'subtle'),
                LiquidGlassAction(title: 'Regular', value: 'regular'),
                LiquidGlassAction(title: 'Prominent', value: 'prominent'),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Native date and time pickers',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: pickDate,
              child: Text(
                'Pick date: ${selectedDate.month}/${selectedDate.day}',
              ),
            ),
            const SizedBox(height: 12),
            LiquidGlassButton(
              onPressed: pickTime,
              child: Text('Pick time: ${selectedTime.format(context)}'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native share sheet',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: share,
              child: const Text('Share text'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> showActionSheet() async {
    await showLiquidGlassActionSheet(
      context: context,
      title: 'Native action',
      message: 'Uses UIKit on iOS and a Flutter fallback elsewhere.',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(
          title: 'Continue',
          value: 'continue',
          role: LiquidGlassActionRole.preferred,
        ),
        LiquidGlassAction(
          title: 'Delete',
          value: 'delete',
          role: LiquidGlassActionRole.destructive,
        ),
      ],
    );
  }

  Future<void> showAlert() async {
    await showLiquidGlassAlert(
      context: context,
      title: 'Native alert',
      message: 'This uses the system alert controller on iOS.',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(
          title: 'OK',
          value: 'ok',
          role: LiquidGlassActionRole.preferred,
        ),
      ],
    );
  }

  Future<void> pickDate() async {
    final date = await showLiquidGlassDatePicker(
      context: context,
      initialDate: selectedDate,
      minimumDate: DateTime(2020),
      maximumDate: DateTime(2030),
      title: 'Select date',
    );

    if (date != null && mounted) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showLiquidGlassTimePicker(
      context: context,
      initialTime: selectedTime,
      title: 'Select time',
    );

    if (time != null && mounted) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> share() async {
    await showLiquidGlassShareSheet(
      context: context,
      items: const <String>['Native Liquid Glass Flutter package'],
    );
  }
}
