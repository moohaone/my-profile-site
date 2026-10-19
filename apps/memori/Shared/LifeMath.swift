import Foundation

/// Every number memori shows comes from here, so the app and the widget agree.
enum LifeMath {
    /// 국가데이터처(구 통계청) 「2024년 생명표」 기대수명. Users can override it in Settings.
    static let defaultLifeExpectancy = 83.7
    static let weeksPerYear = 52.0
    /// Statutory 40-hour week: 40 × 52.14 ÷ 12 ≈ 209 hours a month.
    static let monthlyWorkHours = 209.0
    static let wakingHoursPerDay = 16.0
    private static let daysPerYear = 365.2425

    // MARK: Time

    static func age(birthDate: Date, now: Date = .now) -> Double {
        max(0, now.timeIntervalSince(birthDate) / 86_400 / daysPerYear)
    }

    /// People are entered by age, not birthday, so assume a mid-year birthday.
    static func age(birthYear: Int, now: Date = .now, calendar: Calendar = .current) -> Double {
        let year = calendar.component(.year, from: now)
        return max(0, Double(year - birthYear) - 0.5 + yearFractionElapsed(now: now, calendar: calendar))
    }

    static func yearsLeft(age: Double, lifeExpectancy: Double) -> Double {
        max(0, lifeExpectancy - age)
    }

    static func weeksLeft(age: Double, lifeExpectancy: Double) -> Int {
        Int((yearsLeft(age: age, lifeExpectancy: lifeExpectancy) * weeksPerYear).rounded(.down))
    }

    static func weeksLived(age: Double) -> Int {
        Int((age * weeksPerYear).rounded(.down))
    }

    static func totalWeeks(lifeExpectancy: Double) -> Int {
        Int((lifeExpectancy * weeksPerYear).rounded(.up))
    }

    static func summersLeft(age: Double, lifeExpectancy: Double) -> Int {
        Int(yearsLeft(age: age, lifeExpectancy: lifeExpectancy).rounded(.down))
    }

    static func yearFractionElapsed(now: Date = .now, calendar: Calendar = .current) -> Double {
        guard let year = calendar.dateInterval(of: .year, for: now) else { return 0 }
        return now.timeIntervalSince(year.start) / year.duration
    }

    // MARK: People

    /// Meetings left with someone, counted from the start of this year so that
    /// recording a meeting removes exactly one. Meetings not had by year end are
    /// lost when the year turns, which is the point.
    static func meetingsLeft(
        myAge: Double,
        theirAge: Double,
        perYear: Double,
        meetingsThisYear: Int,
        yearFractionElapsed: Double,
        lifeExpectancy: Double
    ) -> Int {
        let shared = min(
            yearsLeft(age: myAge, lifeExpectancy: lifeExpectancy),
            yearsLeft(age: theirAge, lifeExpectancy: lifeExpectancy)
        )
        guard shared > 0, perYear > 0 else { return 0 }
        let planned = Int(((shared + yearFractionElapsed) * perYear).rounded())
        return max(0, planned - meetingsThisYear)
    }

    // MARK: Money

    static func workHours(price: Int, monthlyIncome: Int) -> Double? {
        guard monthlyIncome > 0, price >= 0 else { return nil }
        let hourly = Double(monthlyIncome) / monthlyWorkHours
        return Double(price) / hourly
    }

    /// Fraction (0...1) of the waking hours you have left.
    static func shareOfWakingLife(hours: Double, age: Double, lifeExpectancy: Double) -> Double {
        let waking = yearsLeft(age: age, lifeExpectancy: lifeExpectancy) * 365 * wakingHoursPerDay
        return waking > 0 ? hours / waking : 0
    }
}
