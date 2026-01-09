import SwiftUI

/// 情報の並び替え（ドラッグ＆ドロップ）を制御するデリゲート
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
                    // move(fromOffsets:toOffset:) は挿入位置を指定するため
                    // to が from より大きい場合は +1 する必要がある
                    items.move(fromOffsets: IndexSet(integer: from),
                               toOffset: to > from ? to + 1 : to)
                }
            }
        }
    }
}
