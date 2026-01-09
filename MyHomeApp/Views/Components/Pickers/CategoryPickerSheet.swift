import SwiftUI

/// モノのカテゴリを選択するためのシート
struct CategoryPickerSheet: View {
    @Binding var categoryName: String
    @Environment(\.dismiss) var dismiss
    
    let categories = [
        "家電", "インテリア", "日用品", "キッチン", "ガーデニング",
        "ファッション", "乗り物", "書籍", "ゲーム", "ホビー",
        "医薬品", "ペット", "その他"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nordicBackground.ignoresSafeArea()
                
                List {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            categoryName = category
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: NordicTheme.categoryIcon(for: category))
                                    .foregroundStyle(NordicTheme.iconColor(for: category))
                                    .frame(width: 30.0)
                                
                                Text(category)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(Color.nordicText)
                                
                                Spacer()
                                
                                if categoryName == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(NordicTheme.iconColor(for: category))
                                }
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("カテゴリを選択")
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
