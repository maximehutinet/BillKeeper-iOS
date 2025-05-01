import SwiftUI

struct BillListView: View {
    @Binding var bills: [Bill]
    @Binding var selectedBillId: UUID?
        
    var body: some View {
            List(bills, selection: $selectedBillId) { bill in
                VStack(alignment: .leading) {
                    if let serviceDateTime = bill.serviceDateTime {
                        Text(serviceDateTime.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                    Text(bill.name ?? "N/S")
                        .font(.headline)
                    Text("Provider: \(bill.provider ?? "N/S")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Beneficiary: \(bill.beneficiary?.firstname ?? "N/S")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(bill.amount != nil
                         ? "Amount: \(bill.amount!, specifier: "%.2f") \(bill.currency?.rawValue ?? "")"
                         : "Amount: N/S")
                    .font(.body)
                    .foregroundColor(.primary)
                    
                }
                .padding(.vertical, 4)
            }
        }
}
