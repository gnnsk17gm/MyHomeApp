import SwiftUI

/// メモの入力セクション
struct FormMemoSection: View {
    @Binding var memo: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                Image(systemName: "note.text").foregroundStyle(Color.nordicBlue)
                Text("暮らしのメモ").font(.system(.subheadline, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicSecondaryText)
            }
            TextField("大切にしたいことなど...", text: $memo, axis: .vertical)
                .font(.system(.body, design: .rounded)).lineSpacing(6.0).frame(minHeight: 80.0, alignment: .top)
        }
        .padding(24.0).nordicCard()
    }
}
