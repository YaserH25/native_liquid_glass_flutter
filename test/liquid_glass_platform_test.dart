import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      message: 'Message',
      cancelTitle: 'Dismiss',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'Continue', value: 'continue'),
      ],
    );

    expect(result, 'continue');
    expect(receivedCall?.method, 'showActionSheet');
    expect(receivedCall?.arguments, containsPair('title', 'Title'));
    expect(receivedCall?.arguments, containsPair('message', 'Message'));
    expect(receivedCall?.arguments, containsPair('cancelTitle', 'Dismiss'));
    expect(
      receivedCall?.arguments,
      containsPair('actions', const <Map<String, Object?>>[
        <String, Object?>{
          'title': 'Continue',
          'value': 'continue',
          'role': 'normal',
          'enabled': true,
        },
      ]),
    );
  });

  test('alert sends required bridge keys on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return 'ok';
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showAlert(
      title: 'Title',
      message: 'Message',
      actions: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'OK', value: 'ok'),
      ],
    );

    expect(result, 'ok');
    expect(receivedCall?.method, 'showAlert');
    expect(receivedCall?.arguments, containsPair('title', 'Title'));
    expect(receivedCall?.arguments, containsPair('message', 'Message'));
    expect(
      receivedCall?.arguments,
      containsPair('actions', const <Map<String, Object?>>[
        <String, Object?>{
          'title': 'OK',
          'value': 'ok',
          'role': 'normal',
          'enabled': true,
        },
      ]),
    );
  });

  test('time picker sends required bridge keys on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return 9 * 60 + 30;
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.showTimePicker(
      initialTime: const TimeOfDay(hour: 9, minute: 15),
      confirmTitle: 'Choose',
      cancelTitle: 'Close',
      minuteInterval: 15,
    );

    expect(result, const TimeOfDay(hour: 9, minute: 30));
    expect(receivedCall?.method, 'showTimePicker');
    expect(
      receivedCall?.arguments,
      containsPair('initialMinutes', 9 * 60 + 15),
    );
    expect(receivedCall?.arguments, containsPair('minuteInterval', 15));
    expect(receivedCall?.arguments, containsPair('confirmTitle', 'Choose'));
    expect(receivedCall?.arguments, containsPair('cancelTitle', 'Close'));
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
    final minimumDate = DateTime(2026, 1, 1);
    final maximumDate = DateTime(2026, 12, 31);
    final result = await platform.showDatePicker(
      initialDate: date,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
    );

    expect(result, date);
    expect(receivedCall?.method, 'showDatePicker');
    expect(
      receivedCall?.arguments,
      containsPair('initialDate', date.millisecondsSinceEpoch),
    );
    expect(
      receivedCall?.arguments,
      containsPair('minimumDate', minimumDate.millisecondsSinceEpoch),
    );
    expect(
      receivedCall?.arguments,
      containsPair('maximumDate', maximumDate.millisecondsSinceEpoch),
    );
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
      message: 'Choose a glass intensity.',
      cancelTitle: 'Close',
      options: const <LiquidGlassAction>[
        LiquidGlassAction(title: 'Regular', value: 'regular'),
      ],
    );

    expect(result, 'regular');
    expect(receivedCall?.method, 'showOptionPicker');
    expect(receivedCall?.arguments, containsPair('title', 'Intensity'));
    expect(
      receivedCall?.arguments,
      containsPair('message', 'Choose a glass intensity.'),
    );
    expect(receivedCall?.arguments, containsPair('cancelTitle', 'Close'));
    expect(
      receivedCall?.arguments,
      containsPair('actions', const <Map<String, Object?>>[
        <String, Object?>{
          'title': 'Regular',
          'value': 'regular',
          'role': 'normal',
          'enabled': true,
        },
      ]),
    );
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
    expect(
      receivedCall?.arguments,
      containsPair('items', const <String>['Text']),
    );
  });

  test('cancel presented overlay calls native channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return true;
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.cancelPresentedOverlay();

    expect(result, true);
    expect(receivedCall?.method, 'cancelPresentedOverlay');
  });

  test('getPlatformVersion uses bridge method constant', () async {
    MethodCall? receivedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(LiquidGlassPlatform.channel, (call) async {
          receivedCall = call;
          return 'iOS 26.0';
        });

    const platform = LiquidGlassPlatform();
    final result = await platform.getPlatformVersion();

    expect(result, 'iOS 26.0');
    expect(receivedCall?.method, 'getPlatformVersion');
  });
}
