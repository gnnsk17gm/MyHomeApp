import SwiftUI

/// アプリ全体のテーマや共通ロジックを管理する
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
        
        if year > 0 {
            return "お迎えして \(year)年" + (month > 0 ? " \(month)ヶ月" : "")
        } else if month > 0 {
            return "お迎えして \(month)ヶ月"
        } else {
            return day == 0 ? "今日お迎え！" : "お迎えして \(day)日"
        }
    }
}
