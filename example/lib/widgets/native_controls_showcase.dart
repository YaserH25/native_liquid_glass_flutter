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
  String buttonResult = 'No button pressed';

  static const List<String> segmentLabels = <String>[
    'Subtle',
    'Regular',
    'Bold',
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseList(
      children: <Widget>[
        ExampleSection(
          title: 'Buttons',
          children: <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                LiquidGlassButton(
                  prominent: true,
                  onPressed: () {
                    setState(() => buttonResult = 'Primary pressed');
                  },
                  child: const Text('Primary'),
                ),
                LiquidGlassButton(
                  onPressed: () {
                    setState(() => buttonResult = 'Secondary pressed');
                  },
                  child: const Text('Secondary'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(buttonResult),
          ],
        ),
        ExampleSection(
          title: 'Native slider',
          children: <Widget>[
            Text('Value: ${(sliderValue * 100).round()}%'),
            LiquidGlassSlider(
              value: sliderValue,
              nativePolicy: LiquidGlassNativePolicy.native,
              onChanged: (value) => setState(() => sliderValue = value),
              onChangeEnd: (value) => setState(() => sliderValue = value),
            ),
            LiquidGlassButton(
              prominent: true,
              onPressed: showLiveSliderSheet,
              child: const Text('Open slider sheet'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native switch',
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('State: ${switchValue ? 'On' : 'Off'}')),
                LiquidGlassSwitch(
                  value: switchValue,
                  nativePolicy: LiquidGlassNativePolicy.native,
                  onChanged: (value) => setState(() => switchValue = value),
                ),
              ],
            ),
          ],
        ),
        ExampleSection(
          title: 'Native segmented control',
          children: <Widget>[
            Text('Selection: ${segmentLabels[segmentIndex]}'),
            const SizedBox(height: 10),
            LiquidGlassSegmentedControl(
              selectedIndex: segmentIndex,
              nativePolicy: LiquidGlassNativePolicy.native,
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
                  nativePolicy: LiquidGlassNativePolicy.native,
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
