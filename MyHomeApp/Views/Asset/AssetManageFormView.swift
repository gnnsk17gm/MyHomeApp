import SwiftUI
import SwiftData
import PhotosUI

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
    @State private var draggingItem: AssetInfoType?
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var editImageItems: [EditImageItem] = []
    @State private var thumbnailType: Int
    @State private var selectedThumbnailIcon: String
    @State private var selectedThumbnailImageData: Data?
    
    @State private var isIconPickerPresented = false
    @State private var isCategoryPickerPresented = false
    @State private var isThumbnailPhotoPickerPresented = false
    @State private var selectedThumbnailPhotoItem: PhotosPickerItem? = nil
    @State private var croppingImageItem: CroppingImage? = nil
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
                
                formScrollView
                
                FormSaveButtonOverlay(name: name, assetToEdit: assetToEdit, action: saveAsset)
            }
            .navigationTitle("") // タイトルを削除
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

    private var formScrollView: some View {
        ScrollView {
            VStack(spacing: 24.0) {
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
                
                FormInfoSection(
                    infoOrder: $infoOrder,
                    draggingItem: $draggingItem,
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
