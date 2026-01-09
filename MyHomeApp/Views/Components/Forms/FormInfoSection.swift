import SwiftUI

/// 情報の入力と並び替えを同時に行える統合セクション
struct FormInfoSection: View {
    // 並び替え用の状態
    @Binding var infoOrder: [AssetInfoType]
    @Binding var draggingItem: AssetInfoType?
    
    // 入力値のバインディング
    @Binding var purchaseDate: Date
    @Binding var maker: String
    @Binding var modelNumber: String
    @Binding var urlTitle: String
    @Binding var url: String
    @Binding var isDatePickerShowing: Bool
    
    var body: some View {
        VStack(spacing: 0.0) {
            ForEach(infoOrder, id: \.self) { type in
                HStack(spacing: 0) {
                    // 1. ドラッグハンドル（左端に配置）
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color.nordicSecondaryText.opacity(0.3))
                        .padding(.leading, 16)
                        .frame(width: 44, height: 70) // 掴みやすいサイズ
                    
                    // 2. 実際の入力行（FormRowをベースに構築）
                    formRow(for: type)
                }
                .background(Color.white)
                .contentShape(Rectangle())
                .opacity(draggingItem == type ? 0.3 : 1.0)
                // ドラッグ＆ドロップのロジック
                .onDrag {
                    self.draggingItem = type
                    return NSItemProvider(object: type.rawValue as NSString)
                }
                .onDrop(of: [.text], delegate: InfoOrderDropDelegate(item: type, items: $infoOrder, draggingItem: $draggingItem))
                
                // 最後の要素以外に区切り線を入れる
                if type != infoOrder.last {
                    Divider().padding(.leading, 60)
                }
            }
        }
        .nordicCard()
    }
    
    /// 各タイプに応じた入力フィールドを生成
    @ViewBuilder
    private func formRow(for type: AssetInfoType) -> some View {
        FormRow(icon: type.iconName, title: type.displayName) {
            switch type {
            case .purchaseDate:
                Button {
                    isDatePickerShowing = true
                } label: {
                    HStack {
                        Text(purchaseDate.formatted(date: .numeric, time: .omitted))
                        Spacer()
                    }
                }
                .popover(isPresented: $isDatePickerShowing) {
                    VStack {
                        DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                            // ★ここがポイント！日本語ロケールを強制して「YYYY年MM月」表記にするよ✨
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .environment(\.calendar, Calendar(identifier: .gregorian))
                        
                        Button("決定") {
                            isDatePickerShowing = false
                        }
                        .font(.system(.headline, design: .rounded))
                        .padding()
                    }
                    .presentationDetents([.medium])
                    .frame(minWidth: 320)
                }
                
            case .maker:
                TextField("未設定", text: $maker)
                    .textFieldStyle(.plain)
                
            case .modelNumber:
                TextField("未設定", text: $modelNumber)
                    .textFieldStyle(.plain)
                
            case .link:
                VStack(alignment: .leading, spacing: 8) {
                    TextField("公式サイトなど", text: $urlTitle)
                        .textFieldStyle(.plain)
                    Divider()
                    TextField("https://...", text: $url)
                        .textFieldStyle(.plain)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                .padding(.vertical, 4)
            }
        }
    }
}
