import SwiftUI

class ImageUtils {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func compressImage(compressionQuality: CGFloat = 0.8) -> ImageUtils {
        if let compressedData = self.image.jpegData(compressionQuality: compressionQuality) {
            self.image = UIImage(data: compressedData)!
        }
        return self
    }
    
    func getImage() -> UIImage {
        return self.image
    }
}
