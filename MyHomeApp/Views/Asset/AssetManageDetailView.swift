import SwiftUI
import SwiftData

struct AssetManageDetailView: View {
    let asset: AssetManage
    
    // 編集画面の表示フラグ
    @State private var isShowingEditView = false
    // 全画面画像ビューワーの表示管理
    @State private var selectedImageIndex: Int? = nil
    
    init(asset: AssetManage) {
        self.asset = asset
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.nordicBackground)
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            Color.nordicBackground.ignoresSafeArea()
            
            detailContentView
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // --- 1. 状態変更時のアニメーション無効化 ---
                Button {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true // アニメーションを無効化
                    withTransaction(transaction) {
                        isShowingEditView = true
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.nordicBlue)
                }
            }
        }
        // --- 2. 閉じる際のアニメーション無効化（カスタムBinding） ---
        .fullScreenCover(isPresented: Binding(
            get: { isShowingEditView },
            set: { newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true // 閉じる際のアニメーションも無効化
                withTransaction(transaction) {
                    isShowingEditView = newValue
                }
            }
        )) {
            AssetManageFormView(assetToEdit: asset)
        }
        // 画像ギャラリー（こちらは標準のアニメーションを残してリッチな体験に）
        .fullScreenCover(item: Binding(
            get: { selectedImageIndex != nil ? ImageIndexWrapper(index: selectedImageIndex!) : nil },
            set: { selectedImageIndex = $0?.index }
        )) { wrapper in
            PhotoGalleryViewer(images: asset.images, selection: wrapper.index)
        }
    }
    
    private var detailContentView: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                
                // --- ヒーローエリア ---
                VStack(spacing: 16.0) {
                    detailThumbnailView
                        .shadow(color: Color.black.opacity(0.1), radius: 15.0, x: 0.0, y: 8.0)
                    
                    VStack(spacing: 8.0) {
                        detailCategoryBadge
                        
                        Text(asset.name)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.nordicText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40.0)
                    }
                }
                .padding(.top, 20.0)
                .frame(maxWidth: .infinity)
                
                // --- スペック & リンク情報 (共通部品 FormRow を使用) ---
                VStack(spacing: 0.0) {
                    let visibleTypes = asset.infoOrder.filter { type in
                        switch type {
                        case .purchaseDate: return true
                        case .maker: return asset.maker != nil && !asset.maker!.isEmpty
                        case .modelNumber: return asset.modelNumber != nil && !asset.modelNumber!.isEmpty
                        case .link: return asset.url != nil && !asset.url!.isEmpty
                        }
                    }
                    
                    ForEach(Array(visibleTypes.enumerated()), id: \.element) { index, type in
                        Group {
                            switch type {
                            case .purchaseDate:
                                FormRow(icon: type.iconName, title: type.displayName) {
                                    HStack {
                                        Text(asset.purchaseDate.formatted(date: .numeric, time: .omitted))
                                        Spacer()
                                        if let duration = NordicTheme.timeSincePurchase(from: asset.purchaseDate) {
                                            Text(duration)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .padding(.horizontal, 10).padding(.vertical, 4)
                                                .background(Color.nordicBlue.opacity(0.15))
                                                .foregroundStyle(Color.nordicBlue).clipShape(Capsule())
                                        }
                                    }
                                }
                            case .maker:
                                FormRow(icon: type.iconName, title: type.displayName) {
                                    Text(asset.maker ?? "")
                                }
                            case .modelNumber:
                                FormRow(icon: type.iconName, title: type.displayName) {
                                    Text(asset.modelNumber ?? "")
                                }
                            case .link:
                                if let urlString = asset.url, let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        FormRow(icon: type.iconName, title: type.displayName) {
                                            HStack {
                                                Text(asset.urlTitle?.isEmpty == false ? asset.urlTitle! : "公式サイトをみる")
                                                    .fontWeight(.bold).foregroundStyle(Color.nordicBlue)
                                                Spacer()
                                                Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(Color.nordicBlue)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if index < visibleTypes.count - 1 {
                                Divider().padding(.leading, 56.0)
                            }
                        }
                    }
                }
                .nordicCard()
                
                // メモ
                if let memo = asset.memo, !memo.isEmpty {
                    VStack(alignment: .leading, spacing: 12.0) {
                        HStack {
                            Image(systemName: "note.text").foregroundStyle(Color.nordicBlue)
                            Text("暮らしのメモ").font(.system(.subheadline, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicSecondaryText)
                        }
                        Text(memo).font(.system(.body, design: .rounded)).foregroundStyle(Color.nordicText).lineSpacing(6.0)
                    }
                    .padding(24.0).frame(maxWidth: .infinity, alignment: .leading)
                    .nordicCard()
                }
                
                // 写真ギャラリー
                if !asset.images.isEmpty {
                    VStack(alignment: .leading, spacing: 16.0) {
                        HStack {
                            Image(systemName: "photo.on.rectangle").foregroundStyle(Color.nordicBlue)
                            Text("思い出の写真").font(.system(.subheadline, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicSecondaryText)
                            Spacer()
                            Text("\(asset.images.count)枚").font(.system(.caption, design: .rounded)).foregroundStyle(Color.nordicSecondaryText)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
                            ForEach(Array(asset.images.enumerated()), id: \.element.id) { index, assetImage in
                                FormImageTile(data: assetImage.data, isEditing: false)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                    }
                            }
                        }
                    }
                    .padding(24.0)
                    .nordicCard()
                }
                
                Spacer().frame(height: 60.0)
            }
            .padding(.horizontal, 20.0)
        }
    }
    
    private var detailThumbnailView: some View {
        Group {
            if let data = asset.thumbnailImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 140.0, height: 140.0).clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 4))
            } else {
                ZStack {
                    Circle().fill(NordicTheme.iconColor(for: asset.categoryName).opacity(0.1)).frame(width: 140.0, height: 140.0)
                    Image(systemName: asset.thumbnailIconName ?? "photo").font(.system(size: 60.0)).foregroundStyle(NordicTheme.iconColor(for: asset.categoryName))
                }.overlay(Circle().stroke(Color.white, lineWidth: 4))
            }
        }
    }
    
    private var detailCategoryBadge: some View {
        HStack(spacing: 6.0) {
            Image(systemName: NordicTheme.categoryIcon(for: asset.categoryName))
            Text(asset.categoryName)
        }
        .font(.system(.caption, design: .rounded)).fontWeight(.bold)
        .padding(.horizontal, 12.0).padding(.vertical, 6.0)
        .background(NordicTheme.iconColor(for: asset.categoryName).opacity(0.15))
        .foregroundStyle(NordicTheme.iconColor(for: asset.categoryName))
        .clipShape(Capsule())
    }
}

// MARK: - 補助構造体 & ビュー (全画面ビューワー用)

struct ImageIndexWrapper: Identifiable {
    let id = UUID()
    let index: Int
}

struct PhotoGalleryViewer: View {
    let images: [AssetImage]
    @State var selection: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selection) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, assetImage in
                    if let uiImage = UIImage(data: assetImage.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
