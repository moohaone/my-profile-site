import SwiftUI

struct OnboardingView: View {
    @AppStorage(Profile.onboardedKey, store: .shared) private var onboarded = false
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @State private var birthDate = Calendar.current.date(from: DateComponents(year: 1988, month: 1, day: 1)) ?? .now

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("Memento mori").eyebrow()
            Text("언제 태어나셨나요?")
                .font(.mTitle)
                .foregroundStyle(Color.mInk)
            Text("남은 시간을 세기 위한 단 하나의 질문입니다. 이 정보는 기기 밖으로 나가지 않습니다.")
                .font(.mBody)
                .foregroundStyle(Color.mMuted)
                .fixedSize(horizontal: false, vertical: true)

            DatePicker("생년월일", selection: $birthDate, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .frame(maxWidth: .infinity)

            Spacer()

            Button("시작하기") {
                birthInterval = birthDate.timeIntervalSinceReferenceDate
                onboarded = true
            }
            .buttonStyle(.memoriPrimary)
        }
        .padding(24)
        .background(Color.mBackground.ignoresSafeArea())
    }
}
