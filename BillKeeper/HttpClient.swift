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
}

