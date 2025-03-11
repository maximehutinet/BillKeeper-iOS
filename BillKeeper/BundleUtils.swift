import SwiftUI

class BundleUtils {
    
    static func getBundleValue(key: String) -> URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    static func getBundleValue(key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}


