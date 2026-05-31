enum LiquidGlassNativePolicy { automatic, flutter, native }

enum LiquidGlassSurfaceRole { content, chrome, floating, modal }

class LiquidGlassNativeResolver {
  const LiquidGlassNativeResolver({
    required this.isNativeIOS,
    required this.policy,
    this.role = LiquidGlassSurfaceRole.content,
  });

  final bool isNativeIOS;
  final LiquidGlassNativePolicy policy;
  final LiquidGlassSurfaceRole role;

  bool get usesNativeSurface {
    if (!isNativeIOS) {
      return false;
    }

    return switch (policy) {
      LiquidGlassNativePolicy.flutter => false,
      LiquidGlassNativePolicy.native => true,
      LiquidGlassNativePolicy.automatic => switch (role) {
        LiquidGlassSurfaceRole.content => false,
        LiquidGlassSurfaceRole.chrome ||
        LiquidGlassSurfaceRole.floating ||
        LiquidGlassSurfaceRole.modal => true,
      },
    };
  }

  bool get usesNativeControl {
    return isNativeIOS && policy == LiquidGlassNativePolicy.native;
  }
}
