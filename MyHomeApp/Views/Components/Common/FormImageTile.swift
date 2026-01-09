import SwiftUI

/// 正方形の画像パネル（編集時は削除ボタン付き）
struct FormImageTile: View {
    let data: Data
    var isEditing: Bool = true
    let onDelete: (() -> Void)?
    
    init(data: Data, isEditing: Bool = true, onDelete: (() -> Void)? = nil) {
        self.data = data
        self.isEditing = isEditing
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: data) {
                Color.clear
                    .aspectRatio(1.0, contentMode: .fit)
                    .overlay(
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            if isEditing, let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .background(Color.nordicBlue.opacity(0.8).clipShape(Circle()))
                        .padding(4)
                }
            }
        }
    }
}
