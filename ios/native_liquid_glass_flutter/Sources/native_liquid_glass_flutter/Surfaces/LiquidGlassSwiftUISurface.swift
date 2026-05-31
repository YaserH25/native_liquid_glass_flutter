import SwiftUI

@available(iOS 26.0, *)
struct LiquidGlassSwiftUISurface: View {
  let configuration: LiquidGlassSurfaceConfiguration

  var body: some View {
    let tint = Color(
      configuration.tintColor.withAlphaComponent(configuration.tintOpacity)
    )
    let shape = RoundedRectangle(
      cornerRadius: configuration.cornerRadius,
      style: .continuous
    )

    if configuration.interactive {
      shape
        .fill(tint)
        .glassEffect(
          .regular.tint(tint).interactive(),
          in: .rect(cornerRadius: configuration.cornerRadius)
        )
    } else {
      shape
        .fill(tint)
        .glassEffect(
          .regular.tint(tint),
          in: .rect(cornerRadius: configuration.cornerRadius)
        )
    }
  }
}
