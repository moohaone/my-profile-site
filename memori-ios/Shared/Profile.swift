import Foundation

/// Must match the app group in project.yml and both entitlements files.
enum AppGroup {
    static let id = "group.com.yourcompany.memori"
}

extension UserDefaults {
    /// Shared with the widget extension. Falls back to standard defaults so a
    /// misconfigured app group degrades to "widget shows nothing", not a crash.
    static let shared = UserDefaults(suiteName: AppGroup.id) ?? .standard
}

/// The person using memori. Small enough to live in shared defaults rather than SwiftData.
enum Profile {
    static let onboardedKey = "profile.onboarded"
    static let birthDateKey = "profile.birthDate"
    static let lifeExpectancyKey = "profile.lifeExpectancy"
    static let monthlyIncomeKey = "profile.monthlyIncome"

    static func birthDate(in defaults: UserDefaults = .shared) -> Date? {
        guard defaults.bool(forKey: onboardedKey) else { return nil }
        return Date(timeIntervalSinceReferenceDate: defaults.double(forKey: birthDateKey))
    }

    static func lifeExpectancy(in defaults: UserDefaults = .shared) -> Double {
        let value = defaults.double(forKey: lifeExpectancyKey)
        return value > 0 ? value : LifeMath.defaultLifeExpectancy
    }
}

/// What the app hands the widget beyond the profile: the one person to feature.
struct WidgetSnapshot: Codable {
    struct PersonLine: Codable {
        var name: String
        var meetingsLeft: Int
        var nextMeeting: Date?
    }

    var person: PersonLine?

    private static let key = "widget.snapshot"

    static func load(from defaults: UserDefaults = .shared) -> WidgetSnapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    func save(to defaults: UserDefaults = .shared) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
