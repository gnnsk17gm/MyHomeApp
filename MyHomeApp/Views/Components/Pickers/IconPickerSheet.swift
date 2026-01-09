import SwiftUI

/// サムネイル用のアイコンを選択するためのシート
struct IconPickerSheet: View {
    @Binding var selectedIcon: String
    @Binding var thumbnailType: Int
    let categoryName: String
    
    @Environment(\.dismiss) var dismiss
    
    // アプリで使用可能なアイコンリスト
    let availableIcons = [
        "star.fill", "heart.fill", "house.fill", "cart.fill", "tv.fill",
        "washer.fill", "lightbulb.fill", "gamecontroller.fill", "drop.fill",
        "sparkles", "fork.knife", "tshirt.fill", "leaf.fill", "bolt.fill",
        "flame.fill", "umbrella.fill", "hammer.fill", "wrench.and.screwdriver.fill",
        "briefcase.fill", "gift.fill", "bed.double.fill", "sofa.fill",
        "chair.lounge.fill", "speaker.wave.2.fill"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nordicBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60.0))], spacing: 20.0) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                                thumbnailType = 1 // アイコンモード
                                dismiss()
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 60.0, height: 60.0)
                                    .background(selectedIcon == icon ? NordicTheme.iconColor(for: categoryName) : Color.white)
                                    .foregroundStyle(selectedIcon == icon ? .white : Color.nordicSecondaryText)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.05), radius: 4.0, x: 0.0, y: 2.0)
                            }
                        }
                    }
                    .padding(24.0)
                }
            }
            .navigationTitle("アイコンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(Color.nordicSecondaryText)
                }
            }
        }
    }
}
