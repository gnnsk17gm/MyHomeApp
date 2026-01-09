import SwiftUI

/// 写真を正方形に調整するためのビュー
struct ThumbnailCropperView: View {
    let image: UIImage
    let onDone: (Data?) -> Void
    let onCancel: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let cropFrameSize: CGFloat = 280
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                
                // クロップ枠のマスク
                ZStack {
                    Color.black.opacity(0.6)
                        .mask(
                            Rectangle()
                                .overlay(
                                    Circle()
                                        .frame(width: cropFrameSize, height: cropFrameSize)
                                        .blendMode(.destinationOut)
                                )
                        )
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: cropFrameSize, height: cropFrameSize)
                }
                .allowsHitTesting(false)
            }
            .navigationTitle("サムネイルの調整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル", action: onCancel)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("決定") {
                        cropAndSave()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    private func cropAndSave() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
        let croppedImage = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 500, height: 500))
            
            let aspect = image.size.width / image.size.height
            var drawWidth: CGFloat
            var drawHeight: CGFloat
            
            if aspect > 1 {
                drawHeight = 500 * scale
                drawWidth = drawHeight * aspect
            } else {
                drawWidth = 500 * scale
                drawHeight = drawWidth / aspect
            }
            
            let x = (500 - drawWidth) / 2 + (offset.width * (500 / cropFrameSize))
            let y = (500 - drawHeight) / 2 + (offset.height * (500 / cropFrameSize))
            
            image.draw(in: CGRect(x: x, y: y, width: drawWidth, height: drawHeight))
        }
        
        onDone(croppedImage.jpegData(compressionQuality: 0.8))
    }
}
