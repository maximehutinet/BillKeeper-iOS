import SwiftUI

struct ImageCarrouselView: View {
    @Binding var document: Document?
    @Binding var currentIndex: Int
    var body: some View {
        VStack {
            if document != nil {
                TabView(selection: $currentIndex) {
                    ForEach(0..<document!.images.count, id: \.self) { index in
                        ZStack {
                            Image(uiImage: document!.images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 350)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                
                if document!.images.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<document!.images.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(currentIndex == index ? .blue : .gray.opacity(0.5))
                        }
                    }
                }
            } else {
                Text("No document to show")
            }
        }
    }
}
