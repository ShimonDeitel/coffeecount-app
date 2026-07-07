import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 15

    @Published var items: [CoffeePurchase] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("coffeecount_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: CoffeePurchase) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: CoffeePurchase) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CoffeePurchase) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CoffeePurchase].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [CoffeePurchase] {
        [
        CoffeePurchase(date: Date().addingTimeInterval(-86400), place: "Corner Cafe", amount: "5.75", item: "Latte"),
        CoffeePurchase(date: Date().addingTimeInterval(-172800), place: "Bagel Shop", amount: "8.20", item: "Bagel + coffee"),
        CoffeePurchase(date: Date().addingTimeInterval(-259200), place: "Corner Cafe", amount: "4.50", item: "Cold brew")
        ]
    }
}
