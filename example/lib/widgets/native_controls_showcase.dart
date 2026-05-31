import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';
import 'showcase_list.dart';
import 'slider_sheet_content.dart';

class NativeControlsShowcase extends StatefulWidget {
  const NativeControlsShowcase({super.key});

  @override
  State<NativeControlsShowcase> createState() => NativeControlsShowcaseState();
}

class NativeControlsShowcaseState extends State<NativeControlsShowcase> {
  double sliderValue = 0.54;
  bool switchValue = true;
  int segmentIndex = 1;
  double stepperValue = 3;

  @override
  Widget build(BuildContext context) {
    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Native slider',
          subtitle: 'The value updates continuously while dragging.',
          children: <Widget>[
            Text('${(sliderValue * 100).round()}%'),
            LiquidGlassSlider(
              value: sliderValue,
              onChanged: (value) => setState(() => sliderValue = value),
              onChangeEnd: (value) => setState(() => sliderValue = value),
            ),
            LiquidGlassButton(
              prominent: true,
              onPressed: showLiveSliderSheet,
              child: const Text('Open live slider sheet'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native switch',
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(switchValue ? 'Enabled' : 'Disabled')),
                LiquidGlassSwitch(
                  value: switchValue,
                  onChanged: (value) => setState(() => switchValue = value),
                ),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Native segmented control',
          children: <Widget>[
            LiquidGlassSegmentedControl(
              selectedIndex: segmentIndex,
              onChanged: (index) => setState(() => segmentIndex = index),
              segments: const <LiquidGlassSegment>[
                LiquidGlassSegment(label: 'Subtle'),
                LiquidGlassSegment(label: 'Regular'),
                LiquidGlassSegment(label: 'Bold'),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Native stepper',
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('Count: ${stepperValue.round()}')),
                LiquidGlassStepper(
                  value: stepperValue,
                  min: 0,
                  max: 10,
                  onChanged: (value) => setState(() => stepperValue = value),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> showLiveSliderSheet() async {
    await showLiquidGlassSheet<void>(
      context: context,
      title: const Text('Live text scale'),
      builder: (context) {
        return SliderSheetContent(initialValue: sliderValue);
      },
    );
  }
}
