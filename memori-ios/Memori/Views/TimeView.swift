import SwiftUI

struct TimeView: View {
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @AppStorage(Profile.lifeExpectancyKey, store: .shared) private var lifeExpectancy = LifeMath.defaultLifeExpectancy
    @State private var showSettings = false
    @State private var shareCard: ShareCard?

    var body: some View {
        let age = LifeMath.age(birthDate: Date(timeIntervalSinceReferenceDate: birthInterval))
        let weeksLeft = LifeMath.weeksLeft(age: age, lifeExpectancy: lifeExpectancy)
        let summersLeft = LifeMath.summersLeft(age: age, lifeExpectancy: lifeExpectancy)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memento mori").eyebrow()
                        BigNumber(value: weeksLeft, unit: "주")
                        Text("기대수명 \(lifeExpectancy.formatted())세까지 남은 주. 남은 여름은 \(summersLeft)번.")
                            .muted()
                    }

                    LifeGrid(
                        weeksLived: LifeMath.weeksLived(age: age),
                        totalWeeks: LifeMath.totalWeeks(lifeExpectancy: lifeExpectancy)
                    )

                    HStack(spacing: 16) {
                        legend(color: .mInk, label: "지나온 주")
                        legend(color: .mWalnut, label: "남은 주")
                    }

                    Button("이 숫자 공유하기") {
                        shareCard = ShareCard(
                            eyebrow: "Memento mori",
                            value: summersLeft,
                            unit: "번",
                            caption: "나에게 남은 여름. 남은 주로는 \(weeksLeft.formatted())주."
                        )
                    }
                    .buttonStyle(.memoriSecondary)
                }
                .padding(24)
            }
            .background(Color.mBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("설정")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(item: $shareCard) { ShareCardSheet(card: $0) }
        }
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).muted()
        }
    }
}
