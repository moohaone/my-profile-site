import Foundation
import SwiftData

/// Something the user wants to buy, held for a week and asked about again.
@Model
final class WishItem {
    enum Decision: String {
        case pending, bought, letGo
    }

    static let revisitDelay: TimeInterval = 7 * 86_400

    var uid: UUID = UUID()
    var title: String = ""
    var price: Int = 0
    /// Frozen at creation so a later income change doesn't rewrite history.
    var workHours: Double = 0
    var createdAt: Date = Date.now
    var revisitAt: Date = Date.now
    var decisionRaw: String = Decision.pending.rawValue

    init(title: String, price: Int, workHours: Double, now: Date = .now) {
        self.title = title
        self.price = price
        self.workHours = workHours
        self.createdAt = now
        self.revisitAt = now.addingTimeInterval(Self.revisitDelay)
    }

    var decision: Decision {
        get { Decision(rawValue: decisionRaw) ?? .pending }
        set { decisionRaw = newValue.rawValue }
    }

    func isDue(now: Date = .now) -> Bool {
        decision == .pending && revisitAt <= now
    }
}
