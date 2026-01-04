import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色を北欧パレットのオフホワイトに！
                Color.nordicBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 48) {
                    Spacer()
                    
                    // シンボルも少し柔らかい印象に
                    ZStack {
                        Circle()
                            .fill(Color.nordicBlue.opacity(0.15))
                            .frame(width: 180, height: 180)
                        
                        Image(systemName: "house.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.nordicBlue)
                    }
                    
                    VStack(spacing: 12) {
                        Text("MyHomeApp")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.nordicText)
                        
                        Text("大切なモノたちとの暮らしを記録しよう")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.nordicSecondaryText)
                    }
                    
                    Spacer()
                    
                    // 画面遷移ボタンをカード風にアレンジ
                    NavigationLink {
                        AssetManageListView()
                    } label: {
                        HStack {
                            Image(systemName: "archivebox.fill")
                            Text("資産一覧をみる")
                                .fontWeight(.semibold)
                        }
                        .font(.system(.title3, design: .rounded))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.nordicBlue)
                        .foregroundStyle(.white)
                        // 要件に合わせてしっかり角を丸く！
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.nordicBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            // ナビゲーションバーの背景を透過させて一体感を出す
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    HomeView()
}
