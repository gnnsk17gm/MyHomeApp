//
//  Color+Extensions.swift
//  MyHomeApp
//
//  Created by Gemini on 2025/11/29.
//

import SwiftUI

// MARK: - Custom Color Palette
// ミッフィの絵本や北欧スタイルを意識した、柔らかく温かみのあるカラーパレットを定義します。
extension Color {
    
    // MARK: - Background Colors
    /// アプリ全体の背景色。柔らかいオフホワイト。
    static let nordicBackground = Color(hex: "FDFCF8")
    /// 二次的な背景色（リストのセルや検索バーなど）。少しグレーがかったオフホワイト。
    static let nordicSecondaryBackground = Color(hex: "F2F0EB")
    
    // MARK: - Text Colors
    /// 主要なテキストの色。真っ黒ではなく、温かみのあるチャコールグレー。
    static let nordicText = Color(hex: "333333")
    /// 二次的なテキストの色（サブタイトルなど）。少し薄いグレー。
    static let nordicSecondaryText = Color(hex: "777777")
    
    // MARK: - Accent Colors (for icons, buttons, etc.)
    /// アクセントカラー1（例: 洗剤）。落ち着いた柔らかいブルー。
    static let nordicBlue = Color(hex: "8FB8D6")
    /// アクセントカラー2（例: 家電）。温かみのある柔らかいイエロー。
    static let nordicYellow = Color(hex: "F3E1A2")
    /// アクセントカラー3（例: 掃除用具）。自然な柔らかいグリーン。
    static let nordicGreen = Color(hex: "A7C4A7")
    /// アクセントカラー4（例: キッチン用品）。優しいオレンジ。
    static let nordicOrange = Color(hex: "F4B793")
    /// アクセントカラー5（例: その他）。落ち着いたピンクベージュ。
    static let nordicPink = Color(hex: "E8C3C3")

    // MARK: - Helper initializer for hex colors
    /// 16進数文字列からColorを作成するためのイニシャライザ
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
