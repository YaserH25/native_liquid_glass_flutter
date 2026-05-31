import SwiftUI

@available(iOS 26.0, *)
struct LiquidGlassSwiftUISurface: View {
  let configuration: LiquidGlassSurfaceConfiguration

  var body: some View {
    let tint = Color(
      configuration.tintColor.withAlphaComponent(configuration.tintOpacity)
    )
    let shape = configuration.swiftUIShape

    shape
      .fill(tint)
      .glassEffect(
        .regular.tint(tint),
        in: shape
      )
  }
}

@available(iOS 26.0, *)
private extension LiquidGlassSurfaceConfiguration {
  var swiftUIShape: LiquidGlassAnyShape {
    switch cornerStyle {
    case "top":
      return LiquidGlassAnyShape(
        UnevenRoundedRectangle(
          cornerRadii: RectangleCornerRadii(
            topLeading: cornerRadius,
            bottomLeading: 0,
            bottomTrailing: 0,
            topTrailing: cornerRadius
          ),
          style: .continuous
        )
      )
    case "none":
      return LiquidGlassAnyShape(Rectangle())
    default:
      return LiquidGlassAnyShape(
        RoundedRectangle(
          cornerRadius: resolvedCornerRadius,
          style: .continuous
        )
      )
    }
  }
}

@available(iOS 26.0, *)
private struct LiquidGlassAnyShape: Shape {
  private let makePath: @Sendable (CGRect) -> Path

  init<S: Shape>(_ shape: S) {
    self.makePath = { rect in
      shape.path(in: rect)
    }
  }

  func path(in rect: CGRect) -> Path {
    return makePath(rect)
  }
}
