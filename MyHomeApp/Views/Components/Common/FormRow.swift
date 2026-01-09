import SwiftUI

/// 詳細画面と編集画面で共通して使用する情報の行
struct FormRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    
    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16.0) {
            // 左側のアイコン
            ZStack {
                Circle()
                    .fill(Color.nordicSecondaryBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.nordicSecondaryText)
            }
            
            // 中央のテキスト（タイトルとコンテンツ）
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.nordicSecondaryText)
                
                content
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.nordicText)
            }
            Spacer()
        }
        .padding(16)
    }
}

#Preview {
    VStack {
        FormRow(icon: "calendar", title: "お迎えした日") {
            Text("2024/01/04")
        }
    }
    .background(Color.nordicBackground)
}
