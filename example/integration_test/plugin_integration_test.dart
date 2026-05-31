import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('platform version is available', (tester) async {
    const platform = LiquidGlassPlatform();
    final version = await platform.getPlatformVersion();

    expect(version?.isNotEmpty, true);
  });
}
