import SwiftUI

enum HttpError: Error {
    case notFound
    case badRequest
    case serverError
    case noInternetConnection
    case invalidUrl
    case networkError
    case invalidData
    case unknown
    case noResponse
    case unauthorized
}

final public class HttpClient {
    
    private var authManager = AuthManager.shared
    
    func baseUrl() -> URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "ServerUrl") as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    func url(path: String) -> URL? {
        baseUrl()?.appendingPathComponent(path)
    }
    
    func getRequest<T: Decodable>(path: String) async throws -> T? {
        guard let url = url(path: path) else {
            throw HttpError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = await authManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw HttpError.noResponse
            }
            try handleHttpResponseStatusCode(code: response.statusCode)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = getCustomDateDecoding()
            return try decoder.decode(T.self, from: data)
        } catch let error {
            try handleError(error: error)
        }
        return nil;
    }
    
    func getCustomDateDecoding() -> JSONDecoder.DateDecodingStrategy {
        return .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ"
            ]
            
            for format in formats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
        }
    }
    
    func sendMultipartRequest(data: Data, filename: String, path: String) async throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let url = url(path: path) else {
            throw HttpError.invalidUrl
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createMultipartBody(
            boundary: boundary,
            data: data,
            mimeType: "application/pdf",
            filename: filename
        )
        
        if let token = await authManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw HttpError.noResponse
            }
            try handleHttpResponseStatusCode(code: response.statusCode)
        } catch let error {
            try handleError(error: error)
        }
    }
    
    func createMultipartBody(boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--".appending(boundary.appending("--")).data(using: .utf8)!)

        return body as Data
    }
    
    func handleError(error: Error) throws {
        if error is HttpError {
            throw error
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                throw HttpError.noInternetConnection
            case .timedOut:
                throw HttpError.networkError
            case .cannotConnectToHost:
                throw HttpError.networkError
            default:
                throw HttpError.unknown
            }
        } else if error is DecodingError {
            throw HttpError.invalidData
        } else {
            throw HttpError.unknown
        }
    }

    func handleHttpResponseStatusCode(code: Int) throws -> Void {
        switch code {
        case 400:
            throw HttpError.badRequest
        case 401:
            throw HttpError.unauthorized
        case 404:
            throw HttpError.notFound
        case (405...499):
            throw HttpError.unknown
        case (500...599):
            throw HttpError.serverError
        default:
            break
        }
    }
    
    static func getAlertMessage(error: HttpError) -> String {
        let baseMessage = "Action failed: "
        return switch error {
        case .networkError:
            baseMessage + "Network error"
        case .unknown:
            baseMessage + "Unknown error"
        case .notFound:
            baseMessage + "Not found"
        case .badRequest:
            baseMessage + "Bad request"
        case .serverError:
            baseMessage + "Server error"
        case .noInternetConnection:
            baseMessage + "No internet connection"
        case .invalidUrl:
            baseMessage + "Invalid URL"
        case .invalidData:
            baseMessage + "Invalid data"
        case .noResponse:
            baseMessage + "No response"
        case .unauthorized:
            baseMessage + "Authentication error"
        }
    }
}

