import SwiftUI
import WidgetKit

struct MemoriEntry: TimelineEntry {
    let date: Date
    let weeksLeft: Int?
    let summersLeft: Int?
    let person: WidgetSnapshot.PersonLine?
}

struct MemoriProvider: TimelineProvider {
    func placeholder(in context: Context) -> MemoriEntry {
        MemoriEntry(
            date: .now,
            weeksLeft: 2_376,
            summersLeft: 45,
            person: .init(name: "엄마", meetingsLeft: 31, nextMeeting: nil)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoriEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : entry(at: .now))
    }

    /// Weeks only change at midnight, so one entry per day is enough.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoriEntry>) -> Void) {
        let now = Date.now
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: [entry(at: now)], policy: .after(tomorrow)))
    }

    private func entry(at date: Date) -> MemoriEntry {
        guard let birthDate = Profile.birthDate() else {
            return MemoriEntry(date: date, weeksLeft: nil, summersLeft: nil, person: nil)
        }
        let age = LifeMath.age(birthDate: birthDate, now: date)
        let lifeExpectancy = Profile.lifeExpectancy()
        return MemoriEntry(
            date: date,
            weeksLeft: LifeMath.weeksLeft(age: age, lifeExpectancy: lifeExpectancy),
            summersLeft: LifeMath.summersLeft(age: age, lifeExpectancy: lifeExpectancy),
            person: WidgetSnapshot.load()?.person
        )
    }
}

struct MemoriWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MemoriEntry

    var body: some View {
        if let weeks = entry.weeksLeft {
            switch family {
            case .accessoryInline:
                Text("남은 \(weeks.formatted())주")
            case .accessoryCircular:
                VStack(spacing: 0) {
                    Text(weeks.formatted())
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("주").font(.system(size: 10))
                }
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("남은 \(weeks.formatted())주")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                    Text(secondLine).font(.system(size: 13))
                }
            default:
                small(weeks: weeks)
            }
        } else {
            Text("앱을 열어 시작하세요")
                .font(.caption)
                .foregroundStyle(Color.mMuted)
        }
    }

    private var secondLine: String {
        if let person = entry.person {
            return "\(person.name) · 남은 만남 \(person.meetingsLeft.formatted())번"
        }
        return "남은 여름 \(entry.summersLeft ?? 0)번"
    }

    private func small(weeks: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Memento mori")
                .font(.system(size: 9, weight: .medium))
                .tracking(1.8)
                .textCase(.uppercase)
                .foregroundStyle(Color.mWalnutDeep)
            Spacer(minLength: 0)
            Text(weeks.formatted())
                .font(.mNumber(40))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(Color.mInk)
            Text("남은 주").font(.system(size: 12)).foregroundStyle(Color.mMuted)
            Rectangle().fill(Color.mLine).frame(height: 1).padding(.vertical, 4)
            Text(secondLine)
                .font(.system(size: 11))
                .foregroundStyle(Color.mInk)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MemoriWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MemoriWidget", provider: MemoriProvider()) { entry in
            MemoriWidgetView(entry: entry)
                .containerBackground(Color.mBackground, for: .widget)
        }
        .configurationDisplayName("남은 시간")
        .description("남은 주, 그리고 한 사람과 남은 만남.")
        .supportedFamilies([.systemSmall, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

@main
struct MemoriWidgetBundle: WidgetBundle {
    var body: some Widget {
        MemoriWidget()
    }
}
