import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, null);
  });

  test('action sheet calls native channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return 'continue';
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showActionSheet(
      title: 'Title',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'Continue', value: 'continue'),
      ],
    );

    expect(result, 'continue');
    expect(receivedCall?.method, 'showActionSheet');
  });

  test('date picker calls native channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;
    final date = DateTime(2026, 5, 31);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return date.millisecondsSinceEpoch;
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showDatePicker(initialDate: date);

    expect(result, date);
    expect(receivedCall?.method, 'showDatePicker');
  });

  test('option picker calls native channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return 'regular';
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showOptionPicker(
      title: 'Intensity',
      options: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'Regular', value: 'regular'),
      ],
    );

    expect(result, 'regular');
    expect(receivedCall?.method, 'showOptionPicker');
  });

  test('share sheet calls native channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return true;
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showShareSheet(items: const <String>['Text']);

    expect(result, true);
    expect(receivedCall?.method, 'showShareSheet');
  });
}
