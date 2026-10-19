import SwiftData
import SwiftUI

struct PersonDetailView: View {
    @Bindable var person: Person
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @AppStorage(Profile.lifeExpectancyKey, store: .shared) private var lifeExpectancy = LifeMath.defaultLifeExpectancy
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showEditor = false
    @State private var showDatePicker = false
    @State private var draftDate = Date.now
    @State private var justMet = false
    @State private var confirmDelete = false
    @State private var shareCard: ShareCard?

    private var myAge: Double {
        LifeMath.age(birthDate: Date(timeIntervalSinceReferenceDate: birthInterval))
    }

    private var meetingsLeft: Int {
        person.meetingsLeft(myAge: myAge, lifeExpectancy: lifeExpectancy)
    }

    private var upcoming: Date? {
        guard let next = person.nextMeeting, next >= Calendar.current.startOfDay(for: .now) else { return nil }
        return next
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(person.name).eyebrow()
                    BigNumber(value: meetingsLeft, unit: "번")
                    Text(caption).muted()
                }

                nextMeetingCard

                VStack(spacing: 12) {
                    Button("오늘 만났어요", action: recordMeeting)
                        .buttonStyle(.memoriPrimary)
                    if justMet {
                        Text("남은 만남이 하나 줄었습니다. 다음 만남을 정해볼까요?")
                            .muted()
                            .transition(.opacity)
                    }
                    Button("이 숫자 공유하기") {
                        shareCard = ShareCard(
                            eyebrow: "Memento mori",
                            value: meetingsLeft,
                            unit: "번",
                            caption: "\(person.name), 지금처럼 만난다면 남은 만남."
                        )
                    }
                    .buttonStyle(.memoriSecondary)
                }

                if !person.meetingDates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("함께한 날").eyebrow()
                        ForEach(Array(person.meetingDates.sorted(by: >).prefix(8)), id: \.self) { date in
                            Text(Format.day(date))
                                .font(.mBody)
                                .foregroundStyle(Color.mInk)
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color.mBackground)
        .sensoryFeedback(.impact(weight: .heavy), trigger: person.meetingDates.count)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("고치기") { showEditor = true }
                    Button("삭제", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showEditor) { PersonEditor(person: person) }
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
        .sheet(item: $shareCard) { ShareCardSheet(card: $0) }
        .confirmationDialog("\(person.name)을(를) 삭제할까요?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive, action: delete)
        }
    }

    private var caption: String {
        let monthly = person.meetingsLeft(myAge: myAge, lifeExpectancy: lifeExpectancy, perYear: 12)
        let base = "지금처럼 1년에 \(person.meetingsPerYear)번 만난다면. 만나지 못한 만남은 해가 바뀌면 사라집니다."
        return person.meetingsPerYear < 12 ? base + " 한 달에 한 번이라면 \(monthly.formatted())번." : base
    }

    private var nextMeetingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("다음 만남").eyebrow()
            if let upcoming {
                Text(Format.day(upcoming))
                    .font(.mTitle)
                    .foregroundStyle(Color.mInk)
                HStack(spacing: 16) {
                    Button("날짜 바꾸기") { openDatePicker() }
                    Button("취소") { setNextMeeting(nil) }
                        .foregroundStyle(Color.mMuted)
                }
                .font(.mBody)
            } else {
                Text("아직 정하지 않았습니다.")
                    .font(.mBody)
                    .foregroundStyle(Color.mMuted)
                Button("다음 만남 정하기") { openDatePicker() }
                    .font(.mHeadline)
            }
        }
        .card()
    }

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker("다음 만남", selection: $draftDate, in: Date.now..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .padding(24)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") { showDatePicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("정하기") {
                            setNextMeeting(draftDate)
                            showDatePicker = false
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }

    private func openDatePicker() {
        draftDate = upcoming ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        showDatePicker = true
    }

    private func setNextMeeting(_ date: Date?) {
        person.nextMeeting = date
        Reminders.scheduleMeeting(uid: person.uid, name: person.name, date: date, meetingsLeft: meetingsLeft)
        WidgetSync.publish(context: context)
    }

    private func recordMeeting() {
        withAnimation(.smooth) {
            person.meetingDates.append(.now)
            justMet = true
        }
        if let next = person.nextMeeting, next < Calendar.current.startOfDay(for: .now).addingTimeInterval(86_400) {
            setNextMeeting(nil)
        } else {
            WidgetSync.publish(context: context)
        }
    }

    /// Dismiss first: SwiftData on iOS 17 can crash if this view reads the
    /// person after the delete is processed.
    private func delete() {
        Reminders.cancelMeeting(uid: person.uid)
        let target = person
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            context.delete(target)
            WidgetSync.publish(context: context)
        }
    }
}
