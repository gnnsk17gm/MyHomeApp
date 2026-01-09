import SwiftUI
import PhotosUI

/// フォトギャラリーの編集セクション
struct FormPhotosSection: View {
    @Binding var editImageItems: [EditImageItem]
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            // 1. ヘッダー部分を切り出し
            headerView
            
            // 2. グリッド部分を切り出し
            if !editImageItems.isEmpty {
                photoGridView
            }
        }
        .padding(24.0)
        .nordicCard() // 共通スタイルを使用
        .onChange(of: selectedPhotoItems) { _, newValue in
            loadImages(from: newValue)
        }
    }
    
    // --- Subviews ---
    
    /// タイトルと追加ボタン
    private var headerView: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
                .foregroundStyle(Color.nordicBlue)
            Text("思い出の写真")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.nordicSecondaryText)
            Spacer()
            
            PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                HStack(spacing: 4.0) {
                    Image(systemName: "plus")
                    Text("追加")
                }
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .padding(.horizontal, 12.0)
                .padding(.vertical, 6.0)
                .background(Color.nordicBlue.opacity(0.1))
                .foregroundStyle(Color.nordicBlue)
                .clipShape(Capsule())
            }
        }
    }
    
    /// 写真のグリッド表示
    @ViewBuilder
    private var photoGridView: some View {
        // 型を明示的に指定してコンパイラを助ける
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4)
        ]
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(editImageItems.indices, id: \.self) { index in
                // 既に共通部品化した Tile を呼び出すだけだからスッキリ！
                FormImageTile(data: editImageItems[index].data) {
                    withAnimation(.spring(response: 0.3)) {
                        // Bindingの値にアクセスするために wrappedValue を使用
                        _ = $editImageItems.wrappedValue.remove(at: index)
                    }
                }
            }
        }
    }
    
    // --- Helpers ---
    
    /// 非同期で画像をロードする処理
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        editImageItems.append(EditImageItem(data: data))
                    }
                }
            }
            await MainActor.run {
                selectedPhotoItems = []
            }
        }
    }
}
