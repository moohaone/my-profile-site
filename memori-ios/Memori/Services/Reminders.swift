import Foundation
import UserNotifications

/// Local notifications only. Nothing leaves the device.
enum Reminders {
    private static var center: UNUserNotificationCenter { .current() }

    private static func meetingID(_ uid: UUID) -> String { "meeting.\(uid.uuidString)" }
    private static func revisitID(_ uid: UUID) -> String { "revisit.\(uid.uuidString)" }

    /// Reminds the day before at 9:00, or the same morning if that has passed.
    static func scheduleMeeting(uid: UUID, name: String, date: Date?, meetingsLeft: Int) {
        cancelMeeting(uid: uid)
        guard let date else { return }

        let calendar = Calendar.current
        let sameDay = morning(of: date)
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: sameDay) else { return }
        guard let fire = [dayBefore, sameDay].first(where: { $0 > .now }) else { return }

        let content = UNMutableNotificationContent()
        content.title = name
        content.body = fire == dayBefore
            ? "내일 만나는 날입니다. 남은 \(meetingsLeft.formatted())번의 만남 중 하나예요."
            : "오늘 만나는 날입니다. 남은 \(meetingsLeft.formatted())번의 만남 중 하나예요."
        content.sound = .default

        add(id: meetingID(uid), content: content, at: fire)
    }

    static func cancelMeeting(uid: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [meetingID(uid)])
    }

    static func scheduleRevisit(uid: UUID, title: String, hours: Double, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "아직도 \(Int(hours.rounded()).formatted())시간의 가치가 있나요?"
        content.sound = .default

        add(id: revisitID(uid), content: content, at: morning(of: date))
    }

    static func cancelRevisit(uid: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [revisitID(uid)])
    }

    private static func morning(of date: Date) -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
    }

    private static func add(id: String, content: UNMutableNotificationContent, at date: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        Task {
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            if granted { try? await center.add(request) }
        }
    }
}
