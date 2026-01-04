// AssetImage.swift
import Foundation
import SwiftData

@Model
final class AssetImage {
    // 画像データ（重いので外部ストレージ保存）
    @Attribute(.externalStorage) var data: Data
    var title: String? // ★追加：画像のタイトル
    var memo: String?  // ★追加：画像のメモ
    var createdAt: Date
    
    init(data: Data, title: String? = nil, memo: String? = nil) {
        self.data = data
        self.title = title
        self.memo = memo
        self.createdAt = Date()
    }
}
