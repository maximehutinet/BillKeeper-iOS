import SwiftUI

struct ImageCarrouselView: View {
    @Binding var document: Document?
    
    var body: some View {
        VStack {
            if document != nil {
                TabView() {
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
                .onAppear() {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .blue
                    UIPageControl.appearance().pageIndicatorTintColor = .gray
                }
            } else {
                Text("No document to show")
            }
        }
    }
}
