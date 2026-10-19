import SwiftData
import SwiftUI

/// Adds a person, or edits one when `person` is set.
struct PersonEditor: View {
    let person: Person?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var age = 65
    @State private var meetingsPerYear = 4

    private var currentYear: Int { Calendar.current.component(.year, from: .now) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("이름 또는 부르는 말 (엄마, 오랜 친구 민수)", text: $name)
                }
                Section {
                    Stepper("나이 \(age)세", value: $age, in: 1...110)
                    Stepper("1년에 \(meetingsPerYear)번 만남", value: $meetingsPerYear, in: 1...365)
                } footer: {
                    Text("지금처럼 만난다면 몇 번이 남았는지 셉니다. 정확하지 않아도 괜찮습니다.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mBackground)
            .navigationTitle(person == nil ? "한 사람 더하기" : "고치기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard let person else { return }
                name = person.name
                age = currentYear - person.birthYear
                meetingsPerYear = person.meetingsPerYear
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if let person {
            person.name = trimmed
            person.birthYear = currentYear - age
            person.meetingsPerYear = meetingsPerYear
        } else {
            context.insert(Person(name: trimmed, birthYear: currentYear - age, meetingsPerYear: meetingsPerYear))
        }
        WidgetSync.publish(context: context)
        dismiss()
    }
}
