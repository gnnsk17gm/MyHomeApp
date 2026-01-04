import SwiftUI
import SwiftData
import PhotosUI

// --- 1. ヘルパー構造体 ---

/// 編集中の画像データを一時保持するための構造体
struct EditImageItem: Identifiable, Hashable {
    let id = UUID()
    var data: Data
    var title: String = ""
    var memo: String = ""
}

/// クロッパーに渡すためのIdentifiableな画像ラッパー
struct CroppingImage: Identifiable {
    let id = UUID()
    let uiImage: UIImage
}

// --- 2. メインView ---

struct AssetManageFormView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var assetToEdit: AssetManage?
    
    // --- 状態管理 ---
    @State private var name: String
    @State private var categoryName: String
    @State private var purchaseDate: Date
    @State private var modelNumber: String
    @State private var maker: String
    @State private var url: String
    @State private var urlTitle: String
    @State private var memo: String
    
    // 並び替え用の状態
    @State private var infoOrder: [AssetInfoType]
    @State private var draggingItem: AssetInfoType? // ドラッグ中のアイテムを保持
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var editImageItems: [EditImageItem] = []
    @State private var thumbnailType: Int
    @State private var selectedThumbnailIcon: String
    @State private var selectedThumbnailImageData: Data?
    
    @State private var isIconPickerPresented = false
    @State private var isCategoryPickerPresented = false
    @State private var isThumbnailPhotoPickerPresented = false
    @State private var selectedThumbnailPhotoItem: PhotosPickerItem? = nil
    
    // クロッパー表示用のアイテム
    @State private var croppingImageItem: CroppingImage? = nil
    
    // 独自カレンダー表示用のフラグ
    @State private var isDatePickerShowing = false

    init(assetToEdit: AssetManage? = nil) {
        self.assetToEdit = assetToEdit
        if let asset = assetToEdit {
            _name = State(initialValue: asset.name)
            _categoryName = State(initialValue: asset.categoryName)
            _purchaseDate = State(initialValue: asset.purchaseDate)
            _modelNumber = State(initialValue: asset.modelNumber ?? "")
            _maker = State(initialValue: asset.maker ?? "")
            _url = State(initialValue: asset.url ?? "")
            _urlTitle = State(initialValue: asset.urlTitle ?? "")
            _memo = State(initialValue: asset.memo ?? "")
            _infoOrder = State(initialValue: asset.infoOrder)
            _editImageItems = State(initialValue: asset.images.map { EditImageItem(data: $0.data, title: $0.title ?? "", memo: $0.memo ?? "") })
            _selectedThumbnailImageData = State(initialValue: asset.thumbnailImageData)
            _selectedThumbnailIcon = State(initialValue: asset.thumbnailIconName ?? "star.fill")
            _thumbnailType = State(initialValue: asset.thumbnailIconName != nil ? 1 : (asset.thumbnailImageData != nil ? 2 : 0))
        } else {
            _name = State(initialValue: "")
            _categoryName = State(initialValue: "家電")
            _purchaseDate = State(initialValue: Date())
            _modelNumber = State(initialValue: "")
            _maker = State(initialValue: "")
            _url = State(initialValue: "")
            _urlTitle = State(initialValue: "")
            _memo = State(initialValue: "")
            _infoOrder = State(initialValue: AssetInfoType.allCases)
            _editImageItems = State(initialValue: [])
            _selectedThumbnailIcon = State(initialValue: "star.fill")
            _selectedThumbnailImageData = State(initialValue: nil)
            _thumbnailType = State(initialValue: 0)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nordicBackground.ignoresSafeArea()
                
                formContentView
                
                FormSaveButtonOverlay(name: name, assetToEdit: assetToEdit, action: saveAsset)
            }
            .navigationTitle(assetToEdit == nil ? "新しいお迎え" : "情報の編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.nordicSecondaryText)
                }
            }
            .sheet(isPresented: $isIconPickerPresented) {
                IconPickerSheet(selectedIcon: $selectedThumbnailIcon, thumbnailType: $thumbnailType, categoryName: categoryName)
            }
            .sheet(isPresented: $isCategoryPickerPresented) {
                CategoryPickerSheet(categoryName: $categoryName)
            }
            .fullScreenCover(item: $croppingImageItem) { item in
                ThumbnailCropperView(image: item.uiImage) { croppedData in
                    self.selectedThumbnailImageData = croppedData
                    self.thumbnailType = 2
                    self.croppingImageItem = nil
                } onCancel: {
                    self.croppingImageItem = nil
                }
            }
        }
    }

    private var formContentView: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                // 1. メインビジュアル
                FormMainVisualSection(
                    name: $name,
                    categoryName: $categoryName,
                    thumbnailType: $thumbnailType,
                    selectedThumbnailIcon: $selectedThumbnailIcon,
                    selectedThumbnailImageData: $selectedThumbnailImageData,
                    isIconPickerPresented: $isIconPickerPresented,
                    isCategoryPickerPresented: $isCategoryPickerPresented,
                    isThumbnailPhotoPickerPresented: $isThumbnailPhotoPickerPresented,
                    selectedThumbnailPhotoItem: $selectedThumbnailPhotoItem,
                    croppingImageItem: $croppingImageItem
                )
                
                // 2. 並び替えセクション（詳細画面と同じレイアウトを適用）
                VStack(spacing: 0) {
                    ForEach(infoOrder, id: \.self) { type in
                        HStack(spacing: 16) {
                            // ドラッグ用のハンドル
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(Color.nordicSecondaryText.opacity(0.3))
                                .padding(.leading, 16)
                            
                            // FormRowと同様のアイコンとテキストの並び
                            ZStack {
                                Circle().fill(Color.nordicSecondaryBackground).frame(width: 40.0, height: 40.0)
                                Image(systemName: type.iconName).font(.system(size: 16.0)).foregroundStyle(Color.nordicSecondaryText)
                            }
                            
                            VStack(alignment: .leading, spacing: 2.0) {
                                Text(type.displayName)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Color.nordicSecondaryText)
                                
                                currentValPreview(for: type)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .contentShape(Rectangle())
                        .opacity(draggingItem == type ? 0.3 : 1.0)
                        .onDrag {
                            self.draggingItem = type
                            return NSItemProvider(object: type.rawValue as NSString)
                        }
                        .onDrop(of: [.text], delegate: InfoOrderDropDelegate(item: type, items: $infoOrder, draggingItem: $draggingItem))
                        
                        if type != infoOrder.last {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .modifier(NordicCardStyle())
                
                // 3. 入力フィールド
                FormInfoSection(
                    purchaseDate: $purchaseDate,
                    maker: $maker,
                    modelNumber: $modelNumber,
                    urlTitle: $urlTitle,
                    url: $url,
                    isDatePickerShowing: $isDatePickerShowing
                )
                
                FormMemoSection(memo: $memo)
                
                FormPhotosSection(
                    editImageItems: $editImageItems,
                    selectedPhotoItems: $selectedPhotoItems
                )
                
                Spacer().frame(height: 120.0)
            }
            .padding(.horizontal, 20.0)
        }
    }
    
    @ViewBuilder
    private func currentValPreview(for type: AssetInfoType) -> some View {
        Group {
            switch type {
            case .purchaseDate:
                Text(purchaseDate.formatted(date: .numeric, time: .omitted))
            case .maker:
                Text(maker.isEmpty ? "未設定" : maker)
            case .modelNumber:
                Text(modelNumber.isEmpty ? "未設定" : modelNumber)
            case .link:
                Text(urlTitle.isEmpty ? "公式サイトなど" : urlTitle)
            }
        }
        .font(.system(.body, design: .rounded))
        .fontWeight(.medium)
        .foregroundStyle(Color.nordicText)
    }

    private func saveAsset() {
        let asset: AssetManage
        if let existingAsset = assetToEdit {
            asset = existingAsset
        } else {
            asset = AssetManage(name: name, purchaseDate: purchaseDate, categoryName: categoryName)
            modelContext.insert(asset)
        }
        
        asset.name = name
        asset.categoryName = categoryName
        asset.purchaseDate = purchaseDate
        asset.modelNumber = modelNumber.isEmpty ? nil : modelNumber
        asset.maker = maker.isEmpty ? nil : maker
        asset.url = url.isEmpty ? nil : url
        asset.urlTitle = urlTitle.isEmpty ? nil : urlTitle
        asset.memo = memo.isEmpty ? nil : memo
        asset.infoOrder = infoOrder
        asset.images = editImageItems.map { AssetImage(data: $0.data, title: $0.title, memo: $0.memo) }
        
        if thumbnailType == 1 {
            asset.thumbnailIconName = selectedThumbnailIcon
            asset.thumbnailImageData = nil
        } else if thumbnailType == 2 {
            asset.thumbnailIconName = nil
            asset.thumbnailImageData = selectedThumbnailImageData
        } else {
            asset.thumbnailIconName = nil
            asset.thumbnailImageData = nil
        }
        
        dismiss()
    }
}

// --- 3. サブビュー・コンポーネント ---

/// 並び替えを実現するためのDropDelegate
struct InfoOrderDropDelegate: DropDelegate {
    let item: AssetInfoType
    @Binding var items: [AssetInfoType]
    @Binding var draggingItem: AssetInfoType?

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }
        if draggingItem != item {
            let from = items.firstIndex(of: draggingItem)!
            let to = items.firstIndex(of: item)!
            if items[to] != draggingItem {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                }
            }
        }
    }
}

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
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        croppingImageItem = CroppingImage(uiImage: uiImage)
                        selectedThumbnailPhotoItem = nil
                    }
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

struct FormInfoSection: View {
    @Binding var purchaseDate: Date
    @Binding var maker: String
    @Binding var modelNumber: String
    @Binding var urlTitle: String
    @Binding var url: String
    @Binding var isDatePickerShowing: Bool
    
    var body: some View {
        VStack(spacing: 0.0) {
            FormRow(icon: "calendar", title: "お迎えした日") {
                Button { isDatePickerShowing = true } label: {
                    HStack {
                        Text(purchaseDate.formatted(date: .numeric, time: .omitted))
                            .font(.system(.body, design: .rounded)).fontWeight(.medium).foregroundStyle(Color.nordicText)
                        Spacer()
                    }
                }
                .popover(isPresented: $isDatePickerShowing) {
                    VStack {
                        DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                            .datePickerStyle(.graphical).padding()
                        Button("決定") { isDatePickerShowing = false }.font(.headline).padding()
                    }
                    .presentationDetents([.medium]).frame(minWidth: 320)
                }
            }
            Divider().padding(.leading, 56.0)
            FormRow(icon: "building.2", title: "メーカー") {
                TextField("未設定", text: $maker).font(.system(.body, design: .rounded)).fontWeight(.medium).textFieldStyle(.plain)
            }
            Divider().padding(.leading, 56.0)
            FormRow(icon: "barcode", title: "品番") {
                TextField("未設定", text: $modelNumber).font(.system(.body, design: .rounded)).fontWeight(.medium).textFieldStyle(.plain)
            }
            Divider().padding(.leading, 56.0)
            FormRow(icon: "link", title: "リンクの表示名") {
                TextField("公式サイトなど", text: $urlTitle).font(.system(.body, design: .rounded)).fontWeight(.medium).textFieldStyle(.plain)
            }
            Divider().padding(.leading, 56.0)
            FormRow(icon: "safari", title: "URL") {
                TextField("https://...", text: $url).font(.system(.body, design: .rounded)).fontWeight(.medium).textFieldStyle(.plain).keyboardType(.URL).autocapitalization(.none)
            }
        }
        .modifier(NordicCardStyle())
    }
}

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
        .padding(24.0).modifier(NordicCardStyle())
    }
}

struct FormPhotosSection: View {
    @Binding var editImageItems: [EditImageItem]
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            HStack {
                Image(systemName: "photo.on.rectangle").foregroundStyle(Color.nordicBlue)
                Text("思い出の写真").font(.system(.subheadline, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicSecondaryText)
                Spacer()
                PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                    HStack(spacing: 4.0) { Image(systemName: "plus"); Text("追加") }
                        .font(.system(.caption, design: .rounded)).fontWeight(.bold).padding(.horizontal, 12.0).padding(.vertical, 6.0)
                        .background(Color.nordicBlue.opacity(0.1)).foregroundStyle(Color.nordicBlue).clipShape(Capsule())
                }
            }
            if !editImageItems.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
                    ForEach(editImageItems.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            if let uiImage = UIImage(data: editImageItems[index].data) {
                                Image(uiImage: uiImage).resizable().scaledToFill().frame(minWidth: 0, maxWidth: .infinity).aspectRatio(1, contentMode: .fill).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button { editImageItems.remove(at: index) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.white).background(Color.nordicBlue.clipShape(Circle())).padding(4)
                            }
                        }
                    }
                }
            }
        }
        .padding(24.0).modifier(NordicCardStyle())
        .onChange(of: selectedPhotoItems) { _, newValue in
            Task {
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        editImageItems.append(EditImageItem(data: data))
                    }
                }
                selectedPhotoItems = []
            }
        }
    }
}

struct FormSaveButtonOverlay: View {
    let name: String; let assetToEdit: AssetManage?; let action: () -> Void
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
    }
}

// --- 4. ピッカー & クロッパー ---

struct IconPickerSheet: View {
    @Binding var selectedIcon: String; @Binding var thumbnailType: Int; let categoryName: String
    @Environment(\.dismiss) var dismiss
    let availableIcons = ["star.fill", "heart.fill", "house.fill", "cart.fill", "tv.fill", "washer.fill", "lightbulb.fill", "gamecontroller.fill", "drop.fill", "sparkles", "fork.knife", "tshirt.fill", "leaf.fill", "bolt.fill", "flame.fill", "umbrella.fill", "hammer.fill", "wrench.and.screwdriver.fill", "briefcase.fill", "gift.fill", "bed.double.fill", "sofa.fill", "chair.lounge.fill", "speaker.wave.2.fill"]
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nordicBackground.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60.0))], spacing: 20.0) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button { selectedIcon = icon; thumbnailType = 1; dismiss() } label: {
                                Image(systemName: icon).font(.title2).frame(width: 60.0, height: 60.0).background(selectedIcon == icon ? NordicTheme.iconColor(for: categoryName) : Color.white).foregroundStyle(selectedIcon == icon ? .white : Color.nordicSecondaryText).clipShape(Circle()).shadow(color: Color.black.opacity(0.05), radius: 4.0, x: 0.0, y: 2.0)
                            }
                        }
                    }.padding(24.0)
                }
            }
            .navigationTitle("アイコンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }.foregroundStyle(Color.nordicSecondaryText)
                }
            }
        }
    }
}

struct CategoryPickerSheet: View {
    @Binding var categoryName: String; @Environment(\.dismiss) var dismiss
    let categories = ["家電", "インテリア", "日用品", "キッチン", "ガーデニング", "ファッション", "乗り物", "書籍", "ゲーム", "ホビー", "医薬品", "ペット", "その他"]
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nordicBackground.ignoresSafeArea()
                List {
                    ForEach(categories, id: \.self) { category in
                        Button { categoryName = category; dismiss() } label: {
                            HStack {
                                Image(systemName: NordicTheme.categoryIcon(for: category)).foregroundStyle(NordicTheme.iconColor(for: category)).frame(width: 30.0)
                                Text(category).fontDesign(.rounded).foregroundStyle(Color.nordicText)
                                Spacer()
                                if categoryName == category { Image(systemName: "checkmark").foregroundStyle(NordicTheme.iconColor(for: category)) }
                            }
                        }.listRowBackground(Color.white)
                    }
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("カテゴリを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }.foregroundStyle(Color.nordicSecondaryText)
                }
            }
        }
    }
}

struct ThumbnailCropperView: View {
    let image: UIImage; let onDone: (Data?) -> Void; let onCancel: () -> Void
    @State private var scale: CGFloat = 1.0; @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero; @State private var lastOffset: CGSize = .zero
    private let cropFrameSize: CGFloat = 280
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Image(uiImage: image).resizable().scaledToFit().scaleEffect(scale).offset(offset)
                    .gesture(DragGesture().onChanged { v in offset = CGSize(width: lastOffset.width + v.translation.width, height: lastOffset.height + v.translation.height) }.onEnded { _ in lastOffset = offset })
                    .simultaneousGesture(MagnificationGesture().onChanged { v in scale = lastScale * v }.onEnded { _ in lastScale = scale })
                ZStack {
                    Color.black.opacity(0.6).mask(Rectangle().overlay(Circle().frame(width: cropFrameSize, height: cropFrameSize).blendMode(.destinationOut)))
                    Circle().stroke(Color.white, lineWidth: 2).frame(width: cropFrameSize, height: cropFrameSize)
                }.allowsHitTesting(false)
            }
            .navigationTitle("サムネイルの調整").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル", action: onCancel).foregroundStyle(.white) }
                ToolbarItem(placement: .confirmationAction) { Button("決定") { cropAndSave() }.fontWeight(.bold).foregroundStyle(.white) }
            }.toolbarBackground(.visible, for: .navigationBar).toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    private func cropAndSave() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
        let croppedImage = renderer.image { ctx in
            let aspect = image.size.width / image.size.height
            let drawW = aspect > 1 ? 500 * scale * aspect : 500 * scale
            let drawH = aspect > 1 ? 500 * scale : (500 * scale) / aspect
            let x = (500 - drawW) / 2 + (offset.width * (500 / cropFrameSize))
            let y = (500 - drawH) / 2 + (offset.height * (500 / cropFrameSize))
            image.draw(in: CGRect(x: x, y: y, width: drawW, height: drawH))
        }
        onDone(croppedImage.jpegData(compressionQuality: 0.8))
    }
}

// --- 5. 共通コンポーネント & テーマ ---

struct FormRow<Content: View>: View {
    let icon: String; let title: String; let content: Content
    init(icon: String, title: String, @ViewBuilder content: () -> Content) { self.icon = icon; self.title = title; self.content = content() }
    var body: some View {
        HStack(spacing: 16.0) {
            ZStack {
                Circle().fill(Color.nordicSecondaryBackground).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(Color.nordicSecondaryText)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.nordicSecondaryText)
                content
            }
            Spacer()
        }.padding(16)
    }
}

struct NordicCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Color.white).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

struct NordicTheme {
    static func categoryIcon(for category: String) -> String {
        switch category {
        case "家電": return "washer.fill"
        case "インテリア": return "chair.lounge.fill"
        case "日用品": return "cart.fill"
        case "キッチン": return "fork.knife"
        case "ガーデニング": return "leaf.fill"
        case "ファッション": return "tshirt.fill"
        case "乗り物": return "car.fill"
        case "書籍": return "book.fill"
        case "ゲーム": return "gamecontroller.fill"
        case "ホビー": return "puzzlepiece.fill"
        case "医薬品": return "pills.fill"
        case "ペット": return "pawprint.fill"
        default: return "questionmark.circle.fill"
        }
    }
    static func iconColor(for category: String) -> Color {
        switch category {
        case "家電": return .nordicYellow
        case "インテリア": return .nordicOrange
        case "日用品": return .nordicBlue
        case "キッチン", "ガーデニング": return .nordicGreen
        case "ファッション", "ゲーム": return .nordicPink
        case "乗り物", "医薬品": return .nordicBlue
        case "書籍", "ペット": return .nordicOrange
        case "ホビー": return .nordicYellow
        default: return .nordicSecondaryText
        }
    }
    static func timeSincePurchase(from date: Date) -> String? {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())
        guard let year = components.year, let month = components.month, let day = components.day else { return nil }
        if date > Date() { return nil }
        if year > 0 { return "お迎えして \(year)年" + (month > 0 ? " \(month)ヶ月" : "") }
        if month > 0 { return "お迎えして \(month)ヶ月" }
        return day == 0 ? "今日お迎え！" : "お迎えして \(day)日"
    }
}
