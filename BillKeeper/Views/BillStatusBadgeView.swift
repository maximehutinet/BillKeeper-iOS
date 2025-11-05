import SwiftUI

struct BillStatusBadgeView: View {
    var status: BillStatus?
    
    var body: some View {
        Text(getStatusValue())
            .foregroundColor(.white)
            .padding(5)
            .background(getStatusColor())
            .cornerRadius(5)
    }
    
    func getStatusValue() -> String {
        switch status {
        case .TO_PAY:
            return "To pay"
        case .TO_FILE:
            return "To file"
        case .FILING_IN_PROGRESS:
            return "Filing in progress"
        case .FILED:
            return "Filed"
        case .REIMBURSEMENT_IN_PROGRESS:
            return "Reimbursement in progress"
        case .REIMBURSED:
            return "Reimbursed"
        case .REJECTED:
            return "Rejected"
        case .none:
            return "N/S"
        }
    }
    
    func getStatusColor() -> Color {
        switch status {
        case .TO_PAY:
            return .orange
        case .TO_FILE:
            return .orange
        case .FILING_IN_PROGRESS:
            return .orange
        case .FILED:
            return .blue
        case .REIMBURSEMENT_IN_PROGRESS:
            return .gray
        case .REIMBURSED:
            return .green
        case .REJECTED:
            return .red
        case .none:
            return .red
        }
    }
    
    
}
