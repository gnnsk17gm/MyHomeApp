import SwiftUI
import SwiftData

struct AssetManageDetailView: View {
    let asset: AssetManage
    
    // 編集画面の表示フラグ
    @State private var isShowingEditView = false
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
                Button {
                    isShowingEditView = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.nordicBlue)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingEditView) {
            AssetManageFormView(assetToEdit: asset)
        }
    }
    
    private var detailContentView: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                
                // --- 1. ヒーローエリア ---
                VStack(spacing: 16.0) {
                    detailThumbnailView
                    
                    VStack(spacing: 8.0) {
                        detailCategoryBadge
                        
                        Text(asset.name)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.nordicText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40.0)
                            .padding(.vertical, 1.0)
                    }
                }
                .padding(.top, 20.0)
                .frame(maxWidth: .infinity)
                
                // --- 2. スペック & リンク情報 (動的な並び替えに対応) ---
                VStack(spacing: 0.0) {
                    // 保存されている infoOrder に基づいて表示
                    let visibleTypes = asset.infoOrder.filter { type in
                        switch type {
                        case .purchaseDate: return true // 日付は常に表示
                        case .maker: return asset.maker != nil && !asset.maker!.isEmpty
                        case .modelNumber: return asset.modelNumber != nil && !asset.modelNumber!.isEmpty
                        case .link: return asset.url != nil && !asset.url!.isEmpty
                        }
                    }
                    
                    ForEach(Array(visibleTypes.enumerated()), id: \.element) { index, type in
                        Group {
                            switch type {
                            case .purchaseDate:
                                detailInfoRow(icon: type.iconName, title: type.displayName) {
                                    HStack {
                                        Text(asset.purchaseDate.formatted(date: .numeric, time: .omitted))
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
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
                                detailInfoRow(icon: type.iconName, title: type.displayName) {
                                    Text(asset.maker ?? "").font(.system(.body, design: .rounded)).fontWeight(.medium)
                                }
                            case .modelNumber:
                                detailInfoRow(icon: type.iconName, title: type.displayName) {
                                    Text(asset.modelNumber ?? "").font(.system(.body, design: .rounded)).fontWeight(.medium)
                                }
                            case .link:
                                if let urlString = asset.url, let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        detailInfoRow(icon: type.iconName, title: type.displayName) {
                                            HStack {
                                                Text(asset.urlTitle?.isEmpty == false ? asset.urlTitle! : "公式サイトをみる")
                                                    .font(.system(.body, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicBlue)
                                                Spacer()
                                                Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(Color.nordicBlue)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 最後の要素以外に区切り線を入れる
                            if index < visibleTypes.count - 1 {
                                Divider().padding(.leading, 56.0)
                            }
                        }
                    }
                }
                .modifier(NordicCardStyle())
                
                // 3. メモ（既存の実装）
                if let memo = asset.memo, !memo.isEmpty {
                    VStack(alignment: .leading, spacing: 12.0) {
                        HStack {
                            Image(systemName: "note.text").foregroundStyle(Color.nordicBlue)
                            Text("暮らしのメモ").font(.system(.subheadline, design: .rounded)).fontWeight(.bold).foregroundStyle(Color.nordicSecondaryText)
                        }
                        Text(memo).font(.system(.body, design: .rounded)).foregroundStyle(Color.nordicText).lineSpacing(6.0)
                    }
                    .padding(24.0).frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(NordicCardStyle())
                }
                
                // 4. 写真ギャラリー（既存の実装）
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
                                if let uiImage = UIImage(data: assetImage.data) {
                                    Button { selectedImageIndex = index } label: {
                                        Color.clear.aspectRatio(1.0, contentMode: .fit)
                                            .overlay(Image(uiImage: uiImage).resizable().scaledToFill())
                                            .clipShape(RoundedRectangle(cornerRadius: 12.0, style: .continuous))
                                    }
                                }
                            }
                        }
                    }
                    .padding(24.0)
                    .modifier(NordicCardStyle())
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
    
    private func detailInfoRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 16.0) {
            ZStack {
                Circle().fill(Color.nordicSecondaryBackground).frame(width: 40.0, height: 40.0)
                Image(systemName: icon).font(.system(size: 16.0)).foregroundStyle(Color.nordicSecondaryText)
            }
            VStack(alignment: .leading, spacing: 2.0) {
                Text(title).font(.system(.caption, design: .rounded)).foregroundStyle(Color.nordicSecondaryText)
                content().foregroundStyle(Color.nordicText)
            }
            Spacer()
        }.padding(16.0)
    }
}
