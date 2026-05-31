import 'package:flutter/services.dart';

import 'liquid_glass_bridge_keys.dart';

class LiquidGlassNativeViewChannel {
  LiquidGlassNativeViewChannel({required this.nameForViewId});

  final String Function(int viewId) nameForViewId;
  MethodChannel? _channel;
  String? _lastSignature;

  bool get isAttached => _channel != null;

  void attach(
    int viewId, {
    required Future<void> Function(MethodCall call) handler,
  }) {
    detach();
    _channel = MethodChannel(nameForViewId(viewId));
    _channel?.setMethodCallHandler(handler);
    _lastSignature = null;
  }

  void detach() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _lastSignature = null;
  }

  Future<void> sync(
    Map<String, Object?> configuration, {
    bool force = false,
    String method = LiquidGlassBridgeMethods.setConfiguration,
    String? signature,
  }) async {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    final nextSignature = signature ?? configuration.toString();
    if (!force && nextSignature == _lastSignature) {
      return;
    }

    _lastSignature = nextSignature;
    await channel.invokeMethod<void>(method, configuration);
  }

  Future<void> invoke(String method, Object? arguments) async {
    await _channel?.invokeMethod<void>(method, arguments);
  }
}
