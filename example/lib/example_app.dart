import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_home_page.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF007A5A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      home: LiquidGlassTheme(
        data: LiquidGlassThemeData.fromColorScheme(colorScheme),
        child: const ExampleHomePage(),
      ),
    );
  }
}
