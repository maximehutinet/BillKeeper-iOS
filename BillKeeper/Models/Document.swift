import Foundation
import UIKit

struct Document: Identifiable {
    let id: UUID
    var images: [UIImage]
    
    init(images: [UIImage]) {
        self.id = UUID()
        self.images = images
    }
}
