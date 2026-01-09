import SwiftUI

/// 画面下部に固定される保存ボタン
struct FormSaveButtonOverlay: View {
    let name: String
    let assetToEdit: AssetManage?
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Button { action() } label: {
                Text(assetToEdit == nil ? "お迎えを記録する" : "変更を保存する")
                    .font(.system(.body, design: .rounded)).fontWeight(.bold).foregroundStyle(.white)
                    .padding(.horizontal, 32.0).padding(.vertical, 16.0)
                    .background(name.isEmpty ? Color.gray.opacity(0.3) : Color.nordicBlue)
                    .clipShape(Capsule()).shadow(color: name.isEmpty ? .clear : Color.nordicBlue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(name.isEmpty).padding(.bottom, 32)
        }
        .ignoresSafeArea(.keyboard)
    }
}
