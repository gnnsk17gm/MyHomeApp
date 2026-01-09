import SwiftUI

/// 並び替えリスト（Reorderable List）で使用する、各項目の行コンポーネント
struct AssetSortRow: View {
    let type: AssetInfoType
    let previewValue: String
    
    var body: some View {
        HStack(spacing: 16) {
            // 並び替え用のハンドルアイコン（ユーザーに掴む場所を明示）
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(Color.nordicSecondaryText.opacity(0.3))
                .padding(.leading, 16)
            
            // アイコン部分（FormRowとデザインを統一）
            ZStack {
                Circle()
                    .fill(Color.nordicSecondaryBackground)
                    .frame(width: 40.0, height: 40.0)
                Image(systemName: type.iconName)
                    .font(.system(size: 16.0))
                    .foregroundStyle(Color.nordicSecondaryText)
            }
            
            // テキスト部分：ラベルと現在の入力値（プレビュー）
            VStack(alignment: .leading, spacing: 2.0) {
                Text(type.displayName)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.nordicSecondaryText)
                
                Text(previewValue)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.nordicText)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

#Preview {
    VStack(spacing: 0) {
        AssetSortRow(type: .purchaseDate, previewValue: "2024/01/08")
        Divider().padding(.leading, 72)
        AssetSortRow(type: .maker, previewValue: "北欧デザイン家具")
    }
    .nordicCard()
    .padding()
    .background(Color.nordicBackground)
}
