import Foundation

struct User: Decodable {
    let id: UUID
    let firstname: String
    let email: String
}
