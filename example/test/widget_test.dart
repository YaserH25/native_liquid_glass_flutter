import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter_example/example_app.dart';

void main() {
  testWidgets('example renders package controls', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Native slider'), findsOneWidget);
    expect(find.text('Open live slider sheet'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
  });
}
