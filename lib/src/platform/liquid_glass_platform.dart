import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../overlays/liquid_glass_action.dart';

class LiquidGlassPlatform {
  const LiquidGlassPlatform();

  static const MethodChannel channel = MethodChannel(
    'native_liquid_glass_flutter',
  );

  static const String surfaceViewType =
      'native_liquid_glass_flutter/liquid_glass_surface';
  static const String sliderViewType =
      'native_liquid_glass_flutter/liquid_glass_slider';
  static const String switchViewType =
      'native_liquid_glass_flutter/liquid_glass_switch';
  static const String segmentedControlViewType =
      'native_liquid_glass_flutter/liquid_glass_segmented_control';
  static const String stepperViewType =
      'native_liquid_glass_flutter/liquid_glass_stepper';

  static bool get isNativeIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<String?> getPlatformVersion() async {
    return channel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> showAlert({
    required String title,
    String? message,
    required List<LiquidGlassAction> actions,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<String>('showAlert', <String, Object?>{
      'title': title,
      'message': message,
      'actions': actions.map((action) => action.toPlatformMap()).toList(),
    });
  }

  Future<String?> showActionSheet({
    required String title,
    String? message,
    required List<LiquidGlassAction> actions,
    String? cancelTitle,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<String>('showActionSheet', <String, Object?>{
      'title': title,
      'message': message,
      'cancelTitle': cancelTitle,
      'actions': actions.map((action) => action.toPlatformMap()).toList(),
    });
  }

  Future<TimeOfDay?> showTimePicker({
    required TimeOfDay initialTime,
    String? title,
    String? confirmTitle,
    String? cancelTitle,
    int minuteInterval = 1,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    final minutes = await channel
        .invokeMethod<int>('showTimePicker', <String, Object?>{
          'initialMinutes': initialTime.hour * 60 + initialTime.minute,
          'minuteInterval': minuteInterval,
          'title': title,
          'confirmTitle': confirmTitle,
          'cancelTitle': cancelTitle,
        });

    if (minutes == null) {
      return null;
    }

    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<DateTime?> showDatePicker({
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    String? title,
    String? confirmTitle,
    String? cancelTitle,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    final milliseconds = await channel
        .invokeMethod<int>('showDatePicker', <String, Object?>{
          'initialDate': initialDate.millisecondsSinceEpoch,
          'minimumDate': minimumDate?.millisecondsSinceEpoch,
          'maximumDate': maximumDate?.millisecondsSinceEpoch,
          'title': title,
          'confirmTitle': confirmTitle,
          'cancelTitle': cancelTitle,
        });

    if (milliseconds == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<String?> showOptionPicker({
    required String title,
    String? message,
    required List<LiquidGlassAction> options,
    String? cancelTitle,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<String>('showOptionPicker', <String, Object?>{
      'title': title,
      'message': message,
      'cancelTitle': cancelTitle,
      'actions': options.map((option) => option.toPlatformMap()).toList(),
    });
  }

  Future<bool?> showShareSheet({required List<String> items}) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<bool>('showShareSheet', <String, Object?>{
      'items': items,
    });
  }
}
