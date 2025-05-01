import Foundation
struct Bill: Decodable, Identifiable {
    let id: UUID
    let dateTime: Date?
    let name: String?
    let amount: Double?
    let user: User
    let currency: Currency?
    let serviceDateTime: Date?
    let paidDateTime: Date?
    let provider: String?
    let status: BillStatus
    let beneficiary: Beneficiary?
    let submissionId: UUID?
    let parsingJobStatus: ParsingJobStatus?
}

enum Currency: String, Decodable {
    case CHF = "CHF"
    case EURO = "EUR"
}

enum BillStatus: String, Decodable {
    case TO_PAY = "TO_PAY"
    case TO_FILE = "TO_FILE"
    case FILING_IN_PROGRESS = "FILING_IN_PROGRESS"
    case FILED = "FILED"
    case REIMBURSEMENT_IN_PROGRESS = "REIMBURSEMENT_IN_PROGRESS"
    case REIMBURSED = "REIMBURSED"
    case REJECTED = "REJECTED"
}
