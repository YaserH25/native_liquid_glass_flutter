import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../overlays/liquid_glass_action.dart';
import 'liquid_glass_bridge_keys.dart';

class LiquidGlassPlatform {
  const LiquidGlassPlatform();

  static const MethodChannel channel = MethodChannel(
    LiquidGlassBridgeChannels.root,
  );

  /// Stable native platform-view IDs exposed for tests and advanced wrappers.
  static const String surfaceViewType =
      LiquidGlassBridgeChannels.surfaceViewType;
  static const String sliderViewType = LiquidGlassBridgeChannels.sliderViewType;
  static const String switchViewType = LiquidGlassBridgeChannels.switchViewType;
  static const String segmentedControlViewType =
      LiquidGlassBridgeChannels.segmentedControlViewType;
  static const String stepperViewType =
      LiquidGlassBridgeChannels.stepperViewType;
  static const String tabBarViewType = LiquidGlassBridgeChannels.tabBarViewType;
  static const String navigationBarViewType =
      LiquidGlassBridgeChannels.navigationBarViewType;
  static const String menuButtonViewType =
      LiquidGlassBridgeChannels.menuButtonViewType;

  /// Stable native method-channel prefixes exposed for tests and advanced wrappers.
  static const String tabBarChannelPrefix =
      LiquidGlassBridgeChannels.tabBarChannelPrefix;
  static const String navigationBarChannelPrefix =
      LiquidGlassBridgeChannels.navigationBarChannelPrefix;
  static const String menuButtonChannelPrefix =
      LiquidGlassBridgeChannels.menuButtonChannelPrefix;

  static bool get isNativeIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<String?> getPlatformVersion() async {
    return channel.invokeMethod<String>(
      LiquidGlassBridgeMethods.getPlatformVersion,
    );
  }

  Future<String?> showAlert({
    required String title,
    String? message,
    required List<LiquidGlassAction> actions,
  }) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<String>(
      LiquidGlassBridgeMethods.showAlert,
      <String, Object?>{
        LiquidGlassBridgeKeys.title: title,
        LiquidGlassBridgeKeys.message: message,
        LiquidGlassBridgeKeys.actions: actions
            .map((action) => action.toPlatformMap())
            .toList(),
      },
    );
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

    return channel.invokeMethod<String>(
      LiquidGlassBridgeMethods.showActionSheet,
      <String, Object?>{
        LiquidGlassBridgeKeys.title: title,
        LiquidGlassBridgeKeys.message: message,
        LiquidGlassBridgeKeys.cancelTitle: cancelTitle,
        LiquidGlassBridgeKeys.actions: actions
            .map((action) => action.toPlatformMap())
            .toList(),
      },
    );
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

    final minutes = await channel.invokeMethod<int>(
      LiquidGlassBridgeMethods.showTimePicker,
      <String, Object?>{
        LiquidGlassBridgeKeys.initialMinutes:
            initialTime.hour * 60 + initialTime.minute,
        LiquidGlassBridgeKeys.minuteInterval: minuteInterval,
        LiquidGlassBridgeKeys.title: title,
        LiquidGlassBridgeKeys.confirmTitle: confirmTitle,
        LiquidGlassBridgeKeys.cancelTitle: cancelTitle,
      },
    );

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

    final milliseconds = await channel.invokeMethod<int>(
      LiquidGlassBridgeMethods.showDatePicker,
      <String, Object?>{
        LiquidGlassBridgeKeys.initialDate: initialDate.millisecondsSinceEpoch,
        LiquidGlassBridgeKeys.minimumDate: minimumDate?.millisecondsSinceEpoch,
        LiquidGlassBridgeKeys.maximumDate: maximumDate?.millisecondsSinceEpoch,
        LiquidGlassBridgeKeys.title: title,
        LiquidGlassBridgeKeys.confirmTitle: confirmTitle,
        LiquidGlassBridgeKeys.cancelTitle: cancelTitle,
      },
    );

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

    return channel.invokeMethod<String>(
      LiquidGlassBridgeMethods.showOptionPicker,
      <String, Object?>{
        LiquidGlassBridgeKeys.title: title,
        LiquidGlassBridgeKeys.message: message,
        LiquidGlassBridgeKeys.cancelTitle: cancelTitle,
        LiquidGlassBridgeKeys.actions: options
            .map((option) => option.toPlatformMap())
            .toList(),
      },
    );
  }

  Future<bool?> showShareSheet({required List<String> items}) async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<bool>(
      LiquidGlassBridgeMethods.showShareSheet,
      <String, Object?>{LiquidGlassBridgeKeys.items: items},
    );
  }

  Future<bool?> cancelPresentedOverlay() async {
    if (!isNativeIOS) {
      return null;
    }

    return channel.invokeMethod<bool>(
      LiquidGlassBridgeMethods.cancelPresentedOverlay,
    );
  }
}
