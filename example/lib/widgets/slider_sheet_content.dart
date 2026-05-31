import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

class SliderSheetContent extends StatefulWidget {
  const SliderSheetContent({super.key, required this.initialValue});

  final double initialValue;

  @override
  State<SliderSheetContent> createState() => SliderSheetContentState();
}

class SliderSheetContentState extends State<SliderSheetContent> {
  late double value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final fontSize = 18 + (value * 18);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Preview text changes while the slider is moving.',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        LiquidGlassSlider(
          value: value,
          onChanged: (nextValue) => setState(() => value = nextValue),
          onChangeEnd: (nextValue) => setState(() => value = nextValue),
        ),
        Text('${(value * 100).round()}%'),
      ],
    );
  }
}
