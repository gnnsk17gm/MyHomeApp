import SwiftUI
import PhotosUI

/// フォームの最上部：画像、カテゴリ、名前の入力
struct FormMainVisualSection: View {
    @Binding var name: String
    @Binding var categoryName: String
    @Binding var thumbnailType: Int
    @Binding var selectedThumbnailIcon: String
    @Binding var selectedThumbnailImageData: Data?
    @Binding var isIconPickerPresented: Bool
    @Binding var isCategoryPickerPresented: Bool
    @Binding var isThumbnailPhotoPickerPresented: Bool
    @Binding var selectedThumbnailPhotoItem: PhotosPickerItem?
    @Binding var croppingImageItem: CroppingImage?
    
    var body: some View {
        VStack(spacing: 16.0) {
            Menu {
                Button { isIconPickerPresented = true } label: { Label("アイコンを選ぶ", systemImage: "star") }
                Button { isThumbnailPhotoPickerPresented = true } label: { Label("写真を選ぶ", systemImage: "photo") }
                if thumbnailType != 0 {
                    Button(role: .destructive) { withAnimation { thumbnailType = 0 } } label: { Label("リセット", systemImage: "trash") }
                }
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    thumbnailPreview
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.nordicBlue)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: 4.0, y: 4.0)
                }
                .shadow(color: Color.black.opacity(0.1), radius: 15.0, x: 0.0, y: 8.0)
            }
            
            VStack(spacing: 8.0) {
                categoryButton
                TextField("モノの名前を入力", text: $name)
                    .font(.system(.title2, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicText)
                    .multilineTextAlignment(.center).textFieldStyle(.plain).padding(.horizontal, 40.0)
            }
        }
        .padding(.top, 20.0)
        .photosPicker(isPresented: $isThumbnailPhotoPickerPresented, selection: $selectedThumbnailPhotoItem, matching: .images)
        .onChange(of: selectedThumbnailPhotoItem) { _, newItem in
            handleThumbnailSelection(newItem)
        }
    }
    
    private func handleThumbnailSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    // ここで CroppingImage を生成してバインディングに渡すよ
                    croppingImageItem = CroppingImage(uiImage: uiImage)
                    selectedThumbnailPhotoItem = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private var thumbnailPreview: some View {
        if thumbnailType == 2, let data = selectedThumbnailImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 140.0, height: 140.0).clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 4))
        } else if thumbnailType == 1 {
            ZStack {
                Circle().fill(NordicTheme.iconColor(for: categoryName).opacity(0.1)).frame(width: 140.0, height: 140.0)
                Image(systemName: selectedThumbnailIcon).font(.system(size: 60.0)).foregroundStyle(NordicTheme.iconColor(for: categoryName))
            }.overlay(Circle().stroke(Color.white, lineWidth: 4))
        } else {
            ZStack {
                Circle().fill(Color.nordicSecondaryBackground).frame(width: 140.0, height: 140.0)
                Image(systemName: "camera.fill").font(.system(size: 40.0)).foregroundStyle(Color.nordicSecondaryText.opacity(0.5))
            }.overlay(Circle().stroke(Color.white, lineWidth: 4))
        }
    }
    
    private var categoryButton: some View {
        Button { isCategoryPickerPresented = true } label: {
            HStack(spacing: 6.0) {
                Image(systemName: NordicTheme.categoryIcon(for: categoryName))
                Text(categoryName)
                Image(systemName: "chevron.right").font(.system(size: 10.0, weight: .bold))
            }
            .font(.system(.caption, design: .rounded)).fontWeight(.bold)
            .padding(.horizontal, 12.0).padding(.vertical, 6.0)
            .background(NordicTheme.iconColor(for: categoryName).opacity(0.15))
            .foregroundStyle(NordicTheme.iconColor(for: categoryName))
            .clipShape(Capsule())
        }
    }
}
