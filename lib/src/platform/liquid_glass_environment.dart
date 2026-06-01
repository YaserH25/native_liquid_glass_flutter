import 'package:flutter/material.dart';

import 'liquid_glass_bridge_keys.dart';

Map<String, Object> liquidGlassEnvironmentConfiguration(BuildContext context) {
  return <String, Object>{
    LiquidGlassBridgeKeys.isDark:
        Theme.of(context).brightness == Brightness.dark,
    LiquidGlassBridgeKeys.isRtl:
        Directionality.of(context) == TextDirection.rtl,
    LiquidGlassBridgeKeys.locale: Localizations.localeOf(
      context,
    ).toLanguageTag(),
  };
}
