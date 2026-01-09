import Foundation
import SwiftData

/// 資産情報の各項目を識別・管理するための列挙型
enum AssetInfoType: String, Codable, CaseIterable {
    case purchaseDate = "purchaseDate"
    case maker = "maker"
    case modelNumber = "modelNumber"
    case link = "link"
    
    var displayName: String {
        switch self {
        case .purchaseDate: return "お迎えした日"
        case .maker: return "メーカー"
        case .modelNumber: return "品番"
        case .link: return "リンク"
        }
    }
    
    var iconName: String {
        switch self {
        case .purchaseDate: return "calendar"
        case .maker: return "building.2"
        case .modelNumber: return "barcode"
        case .link: return "link"
        }
    }
}

@Model
final class AssetManage {
    var name: String
    var modelNumber: String?
    var maker: String?
    var url: String?
    var urlTitle: String?
    var purchaseDate: Date
    var categoryName: String
    var memo: String?
    
    /// 項目の表示順序を保持する（デフォルトは CaseIterable の順）
    var infoOrder: [AssetInfoType] = AssetInfoType.allCases
    
    @Relationship(deleteRule: .cascade) var images: [AssetImage] = []
    
    @Attribute(.externalStorage) var thumbnailImageData: Data?
    var thumbnailIconName: String?
    
    init(name: String, purchaseDate: Date, categoryName: String) {
        self.name = name
        self.purchaseDate = purchaseDate
        self.categoryName = categoryName
        self.infoOrder = AssetInfoType.allCases
        
        self.modelNumber = nil
        self.maker = nil
        self.url = nil
        self.urlTitle = nil
        self.memo = nil
        self.thumbnailImageData = nil
        self.thumbnailIconName = nil
    }
}
