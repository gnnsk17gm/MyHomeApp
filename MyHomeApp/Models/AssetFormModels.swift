import Foundation
import UIKit
import SwiftUI

/// 編集中の画像データを一時保持するための構造体
struct EditImageItem: Identifiable, Hashable {
    let id = UUID()
    var data: Data
    var title: String = ""
    var memo: String = ""
}

/// クロッパーに渡すための画像ラッパー
struct CroppingImage: Identifiable {
    let id = UUID()
    let uiImage: UIImage
}
