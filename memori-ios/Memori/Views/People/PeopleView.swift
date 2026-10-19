import SwiftData
import SwiftUI

struct PeopleView: View {
    @Query(sort: \Person.createdAt) private var people: [Person]
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @AppStorage(Profile.lifeExpectancyKey, store: .shared) private var lifeExpectancy = LifeMath.defaultLifeExpectancy
    @State private var showEditor = false

    var body: some View {
        let myAge = LifeMath.age(birthDate: Date(timeIntervalSinceReferenceDate: birthInterval))

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SectionHeader(
                        eyebrow: "사람",
                        title: "그 사람과 남은 만남",
                        subtitle: people.isEmpty ? "가장 먼저 떠오르는 한 사람을 더해보세요." : nil
                    )

                    if people.isEmpty {
                        Button("한 사람 더하기") { showEditor = true }
                            .buttonStyle(.memoriPrimary)
                    }

                    ForEach(people) { person in
                        NavigationLink(value: person) {
                            PersonRow(
                                person: person,
                                meetingsLeft: person.meetingsLeft(myAge: myAge, lifeExpectancy: lifeExpectancy)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
            .background(Color.mBackground)
            .navigationDestination(for: Person.self) { PersonDetailView(person: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("사람 더하기")
                }
            }
            .sheet(isPresented: $showEditor) { PersonEditor(person: nil) }
        }
    }
}

private struct PersonRow: View {
    let person: Person
    let meetingsLeft: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(person.name)
                    .font(.mHeadline)
                    .foregroundStyle(Color.mInk)
                if let next = person.nextMeeting, next >= Calendar.current.startOfDay(for: .now) {
                    Text("다음 만남 \(Format.day(next))").muted()
                } else {
                    Text("1년에 \(person.meetingsPerYear)번").muted()
                }
            }
            Spacer()
            BigNumber(value: meetingsLeft, unit: "번", size: 40)
        }
        .card()
    }
}
