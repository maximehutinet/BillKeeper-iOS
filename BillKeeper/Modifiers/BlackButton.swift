import SwiftUI

struct BlackButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    private var isLoading: Bool
    
    init(isLoading: Bool = false) {
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(colorScheme == .dark ? .black : .white)
                
            }
            
            configuration.label
                
        }
        .padding()
        .background(colorScheme == .dark ? Color.white : Color.black)
        .foregroundStyle(colorScheme == .dark ? .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}
