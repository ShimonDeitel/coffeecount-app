import Foundation

struct CoffeePurchase: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var place: String
    var amount: String
    var item: String
}
