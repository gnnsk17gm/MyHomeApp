import SwiftUI

/// 北欧風の角丸カードスタイルを適用するModifier
struct NordicCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func nordicCard() -> some View {
        self.modifier(NordicCardStyle())
    }
}
