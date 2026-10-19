import XCTest
@testable import Memori

final class LifeMathTests: XCTestCase {
    private let lifeExpectancy = LifeMath.defaultLifeExpectancy
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }

    // Values match the /memori/time/ landing page defaults.

    func testWeeksAndSummersLeft() {
        XCTAssertEqual(LifeMath.weeksLeft(age: 38, lifeExpectancy: lifeExpectancy), 2_376)
        XCTAssertEqual(LifeMath.summersLeft(age: 38, lifeExpectancy: lifeExpectancy), 45)
    }

    func testNothingLeftPastLifeExpectancy() {
        XCTAssertEqual(LifeMath.weeksLeft(age: 90, lifeExpectancy: lifeExpectancy), 0)
        XCTAssertEqual(LifeMath.summersLeft(age: 90, lifeExpectancy: lifeExpectancy), 0)
    }

    func testAgeFromBirthDate() {
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 19))!
        let birth = calendar.date(byAdding: .year, value: -38, to: now)!
        XCTAssertEqual(LifeMath.age(birthDate: birth, now: now), 38, accuracy: 0.01)
    }

    func testYearFractionElapsed() {
        let newYear = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let midYear = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2, hour: 12))!
        XCTAssertEqual(LifeMath.yearFractionElapsed(now: newYear, calendar: calendar), 0, accuracy: 0.0001)
        XCTAssertEqual(LifeMath.yearFractionElapsed(now: midYear, calendar: calendar), 0.5, accuracy: 0.01)
    }

    func testMeetingsUseTheShorterLifeline() {
        let left = LifeMath.meetingsLeft(
            myAge: 38, theirAge: 68, perYear: 2,
            meetingsThisYear: 0, yearFractionElapsed: 0, lifeExpectancy: lifeExpectancy
        )
        XCTAssertEqual(left, 31)
    }

    func testRecordingAMeetingRemovesExactlyOne() {
        func left(met: Int) -> Int {
            LifeMath.meetingsLeft(
                myAge: 38, theirAge: 68, perYear: 4,
                meetingsThisYear: met, yearFractionElapsed: 0.5, lifeExpectancy: lifeExpectancy
            )
        }
        XCTAssertEqual(left(met: 0) - left(met: 1), 1)
        XCTAssertEqual(left(met: 1) - left(met: 2), 1)
    }

    func testCountHoldsSteadyThroughTheYearWithoutMeetings() {
        // Their age grows with the year fraction, so the count only moves when you meet.
        func left(fraction: Double) -> Int {
            LifeMath.meetingsLeft(
                myAge: 38 + fraction, theirAge: 68 + fraction, perYear: 4,
                meetingsThisYear: 0, yearFractionElapsed: fraction, lifeExpectancy: lifeExpectancy
            )
        }
        XCTAssertEqual(left(fraction: 0.1), left(fraction: 0.9))
    }

    func testNoMeetingsWhenEitherLifelineHasRunOut() {
        let left = LifeMath.meetingsLeft(
            myAge: 38, theirAge: 95, perYear: 12,
            meetingsThisYear: 0, yearFractionElapsed: 0.3, lifeExpectancy: lifeExpectancy
        )
        XCTAssertEqual(left, 0)
    }

    func testWorkHours() throws {
        let hours = try XCTUnwrap(LifeMath.workHours(price: 1_200_000, monthlyIncome: 4_000_000))
        XCTAssertEqual(hours, 62.7, accuracy: 0.05)
        XCTAssertNil(LifeMath.workHours(price: 1_200_000, monthlyIncome: 0))
    }

    func testShareOfWakingLife() {
        let share = LifeMath.shareOfWakingLife(hours: 62.7, age: 38, lifeExpectancy: lifeExpectancy)
        XCTAssertEqual(share * 100, 0.0235, accuracy: 0.001)
        XCTAssertEqual(Format.percent(share), "0.02%")
    }
}
