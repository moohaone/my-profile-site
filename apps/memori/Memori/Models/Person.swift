import Foundation
import SwiftData

@Model
final class Person {
    var uid: UUID = UUID()
    var name: String = ""
    var birthYear: Int = 1958
    var meetingsPerYear: Int = 4
    var nextMeeting: Date?
    var meetingDates: [Date] = []
    var createdAt: Date = Date.now

    init(name: String, birthYear: Int, meetingsPerYear: Int) {
        self.name = name
        self.birthYear = birthYear
        self.meetingsPerYear = meetingsPerYear
    }
}

extension Person {
    func age(now: Date = .now) -> Double {
        LifeMath.age(birthYear: birthYear, now: now)
    }

    func meetingsThisYear(now: Date = .now) -> Int {
        meetingDates.filter { Calendar.current.isDate($0, equalTo: now, toGranularity: .year) }.count
    }

    /// `perYear` overrides the person's own frequency, for "what if" comparisons.
    func meetingsLeft(myAge: Double, lifeExpectancy: Double, now: Date = .now, perYear: Int? = nil) -> Int {
        LifeMath.meetingsLeft(
            myAge: myAge,
            theirAge: age(now: now),
            perYear: Double(perYear ?? meetingsPerYear),
            meetingsThisYear: meetingsThisYear(now: now),
            yearFractionElapsed: LifeMath.yearFractionElapsed(now: now),
            lifeExpectancy: lifeExpectancy
        )
    }
}
