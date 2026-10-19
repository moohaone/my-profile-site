import Foundation
import SwiftData
import WidgetKit

/// The widget computes weeks left from the shared profile on its own.
/// The app only needs to hand over the person to feature.
enum WidgetSync {
    static func publish(context: ModelContext) {
        let people = (try? context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
        let upcoming = people
            .filter { ($0.nextMeeting ?? .distantPast) >= Calendar.current.startOfDay(for: .now) }
            .min { ($0.nextMeeting ?? .distantFuture) < ($1.nextMeeting ?? .distantFuture) }
        let featured = upcoming ?? people.first

        var snapshot = WidgetSnapshot()
        if let featured, let birthDate = Profile.birthDate() {
            snapshot.person = .init(
                name: featured.name,
                meetingsLeft: featured.meetingsLeft(
                    myAge: LifeMath.age(birthDate: birthDate),
                    lifeExpectancy: Profile.lifeExpectancy()
                ),
                nextMeeting: featured.nextMeeting
            )
        }
        snapshot.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
