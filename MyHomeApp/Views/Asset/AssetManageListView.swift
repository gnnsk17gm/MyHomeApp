import SwiftUI
import SwiftData

// ソートの種類
enum SortType: String, CaseIterable, Identifiable {
    case nameAsc = "名前順"
    case dateDesc = "お迎えが新しい順"
    case dateAsc = "お迎えが古い順"
    case category = "カテゴリ順"
    
    var id: String { rawValue }
}

struct AssetManageListView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var searchText: String = ""
    @State private var isShowingAddView = false
    @State private var selectedSortType: SortType = .nameAsc
    @State private var selectedCategory: String? = nil
    
    // 検索バーの表示状態
    @State private var isSearching = false
    
    // カテゴリ一覧
    let categories = [
        "家電", "インテリア", "日用品", "キッチン", "ガーデニング",
        "ファッション", "乗り物", "書籍", "ゲーム", "ホビー",
        "医薬品", "ペット", "その他"
    ]
    
    init() {
        // ナビゲーションバーの背景色を設定
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.nordicBackground)
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.nordicBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. カスタム検索バー
                    if isSearching {
                        searchBarView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // 2. カテゴリチップ
                    categoryFilterScrollView
                        .padding(.vertical, 8)
                    
                    // 3. メインコンテンツ（Queryを制御するサブビュー）
                    AssetListContent(
                        searchText: searchText,
                        sortType: selectedSortType,
                        filterCategory: selectedCategory
                    )
                }
                
                // 4. フローティングアクションボタン (FAB)
                addButton
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // 検索ボタン
                        Button {
                            withAnimation(.spring()) {
                                isSearching.toggle()
                                if !isSearching { searchText = "" }
                            }
                        } label: {
                            Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                                .foregroundStyle(Color.nordicText)
                        }
                        
                        // 並び替えメニュー
                        Menu {
                            Picker("並び替え", selection: $selectedSortType) {
                                ForEach(SortType.allCases) { type in
                                    Label(type.rawValue, systemImage: iconForSortType(type))
                                        .tag(type)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .foregroundStyle(Color.nordicText)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingAddView) {
                AssetManageFormView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBarView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.nordicSecondaryText)
                TextField("名前やカテゴリで検索", text: $searchText)
                    .font(.system(.body, design: .rounded))
                    .textFieldStyle(.plain)
                    .foregroundStyle(Color.nordicText)
            }
            .padding(12)
            .background(Color.nordicSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 「すべて」ボタン
                filterChip(title: "すべて", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(categories, id: \.self) { category in
                    filterChip(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.nordicBlue : Color.white)
                .foregroundStyle(isSelected ? .white : Color.nordicSecondaryText)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    private var addButton: some View {
        Button {
            isShowingAddView = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [Color.nordicBlue, Color.nordicBlue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.nordicBlue.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(24)
    }
    
    private func iconForSortType(_ type: SortType) -> String {
        switch type {
        case .nameAsc: return "abc"
        case .dateDesc: return "calendar.badge.clock"
        case .dateAsc: return "calendar"
        case .category: return "folder"
        }
    }
}

// --- 子View: リスト部分 ---

struct AssetListContent: View {
    @Environment(\.modelContext) var modelContext
    @Query var assets: [AssetManage]
    
    init(searchText: String, sortType: SortType, filterCategory: String?) {
        let sortDescriptors: [SortDescriptor<AssetManage>]
        switch sortType {
        case .nameAsc:
            sortDescriptors = [SortDescriptor(\.name, order: .forward)]
        case .dateDesc:
            sortDescriptors = [SortDescriptor(\.purchaseDate, order: .reverse)]
        case .dateAsc:
            sortDescriptors = [SortDescriptor(\.purchaseDate, order: .forward)]
        case .category:
            sortDescriptors = [SortDescriptor(\.categoryName, order: .forward), SortDescriptor(\.name, order: .forward)]
        }
        
        let filter: Predicate<AssetManage>?
        if searchText.isEmpty {
            if let category = filterCategory {
                filter = #Predicate { $0.categoryName == category }
            } else {
                filter = nil
            }
        } else {
            if let category = filterCategory {
                filter = #Predicate {
                    ($0.name.localizedStandardContains(searchText) || $0.categoryName.localizedStandardContains(searchText))
                    && $0.categoryName == category
                }
            } else {
                filter = #Predicate {
                    $0.name.localizedStandardContains(searchText) ||
                    $0.categoryName.localizedStandardContains(searchText)
                }
            }
        }
        _assets = Query(filter: filter, sort: sortDescriptors)
    }
    
    var body: some View {
        if assets.isEmpty {
            ContentUnavailableView {
                Label("見つかりませんでした", systemImage: "magnifyingglass")
                    .font(.system(.title2, design: .rounded))
                    .foregroundStyle(Color.nordicSecondaryText)
            } description: {
                Text("お迎えしたモノを登録してみよう！")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.nordicSecondaryText)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(assets) { asset in
                        NavigationLink {
                            AssetManageDetailView(asset: asset)
                        } label: {
                            AssetCardRow(asset: asset)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
    }
}

// カードスタイルの行View
struct AssetCardRow: View {
    let asset: AssetManage
    
    var body: some View {
        HStack(spacing: 16) {
            thumbnailView
            
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.nordicText)
                
                HStack {
                    Text(asset.categoryName)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(NordicTheme.iconColor(for: asset.categoryName).opacity(0.15))
                        .foregroundStyle(NordicTheme.iconColor(for: asset.categoryName))
                        .clipShape(Capsule())
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let data = asset.thumbnailImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(NordicTheme.iconColor(for: asset.categoryName).opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: asset.thumbnailIconName ?? NordicTheme.categoryIcon(for: asset.categoryName))
                    .font(.title3)
                    .foregroundStyle(NordicTheme.iconColor(for: asset.categoryName))
            }
        }
    }
}
