import UIKit

final class LiquidGlassPassthroughView: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    return false
  }
}
