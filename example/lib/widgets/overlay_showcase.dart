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
  String selectedMenuOption = 'comfortable';
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 30);
  DateTime selectedDate = DateTime(2026, 5, 31);
  String lastResult = 'No overlay opened';

  @override
  Widget build(BuildContext context) {
    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Bottom sheet',
          children: <Widget>[
            LiquidGlassButton(
              prominent: true,
              onPressed: showBottomSheet,
              child: const Text('Open sheet'),
            ),
            const SizedBox(height: 10),
            Text(lastResult),
          ],
        ),
        ExampleSection(
          title: 'Popup alert',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: showAlert,
              child: const Text('Show alert'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Action sheet',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: showActionSheet,
              child: const Text('Show actions'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native menu',
          children: <Widget>[
            LiquidGlassMenuButton(
              title: 'Density',
              value: selectedMenuOption,
              onChanged: (value) {
                setState(() {
                  selectedMenuOption = value;
                  lastResult = 'Menu: $value';
                });
              },
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Compact', value: 'compact'),
                LiquidGlassAction(
                  title: 'Comfortable',
                  value: 'comfortable',
                  role: LiquidGlassActionRole.preferred,
                ),
                LiquidGlassAction(title: 'Spacious', value: 'spacious'),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Option picker',
          children: <Widget>[
            LiquidGlassPickerButton(
              title: 'Intensity',
              value: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                  lastResult = 'Option: $value';
                });
              },
              options: const <LiquidGlassAction>[
                LiquidGlassAction(title: 'Subtle', value: 'subtle'),
                LiquidGlassAction(title: 'Regular', value: 'regular'),
                LiquidGlassAction(title: 'Prominent', value: 'prominent'),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Date picker',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: pickDate,
              child: Text(
                'Date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
              ),
            ),
          ],
        ),
        ExampleSection(
          title: 'Time picker',
          children: <Widget>[
            LiquidGlassButton(
              onPressed: pickTime,
              child: Text('Time: ${selectedTime.format(context)}'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Share sheet',
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

  Future<void> showBottomSheet() async {
    final result = await showLiquidGlassSheet<String>(
      context: context,
      title: const Text('Bottom sheet'),
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Sheet content'),
            const SizedBox(height: 14),
            LiquidGlassButton(
              prominent: true,
              onPressed: () => Navigator.of(sheetContext).pop('Sheet closed'),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (mounted && result != null) {
      setState(() => lastResult = result);
    }
  }

  Future<void> showActionSheet() async {
    final result = await showLiquidGlassActionSheet(
      context: context,
      title: 'Choose action',
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
        LiquidGlassAction(
          title: 'Cancel',
          value: 'cancel',
          role: LiquidGlassActionRole.cancel,
        ),
      ],
    );

    if (mounted && result != null) {
      setState(() => lastResult = 'Action: $result');
    }
  }

  Future<void> showAlert() async {
    final result = await showLiquidGlassAlert(
      context: context,
      title: 'Confirm change',
      message: 'Choose one option.',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(
          title: 'Cancel',
          value: 'cancel',
          role: LiquidGlassActionRole.cancel,
        ),
        LiquidGlassAction(
          title: 'Apply',
          value: 'apply',
          role: LiquidGlassActionRole.preferred,
        ),
      ],
    );

    if (mounted && result != null) {
      setState(() => lastResult = 'Alert: $result');
    }
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
      setState(() {
        selectedDate = date;
        lastResult = 'Date selected';
      });
    }
  }

  Future<void> pickTime() async {
    final time = await showLiquidGlassTimePicker(
      context: context,
      initialTime: selectedTime,
      title: 'Select time',
    );

    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
        lastResult = 'Time selected';
      });
    }
  }

  Future<void> share() async {
    final completed = await showLiquidGlassShareSheet(
      context: context,
      items: const <String>['Native Liquid Glass Flutter package'],
    );

    if (mounted) {
      setState(
        () => lastResult = completed == true ? 'Shared' : 'Share closed',
      );
    }
  }
}
