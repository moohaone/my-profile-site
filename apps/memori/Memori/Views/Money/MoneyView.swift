import SwiftData
import SwiftUI

struct MoneyView: View {
    @Query(sort: \WishItem.createdAt, order: .reverse) private var wishes: [WishItem]
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @AppStorage(Profile.lifeExpectancyKey, store: .shared) private var lifeExpectancy = LifeMath.defaultLifeExpectancy
    @AppStorage(Profile.monthlyIncomeKey, store: .shared) private var monthlyIncome = 0
    @Environment(\.modelContext) private var context

    @State private var title = ""
    @State private var price: Int?
    @State private var incomeDraft: Int?
    @State private var shareCard: ShareCard?
    @FocusState private var focused: Bool

    private var age: Double {
        LifeMath.age(birthDate: Date(timeIntervalSinceReferenceDate: birthInterval))
    }

    private var pending: [WishItem] { wishes.filter { $0.decision == .pending } }
    private var decided: [WishItem] { wishes.filter { $0.decision != .pending } }
    private var reclaimedHours: Double {
        wishes.filter { $0.decision == .letGo }.reduce(0) { $0 + $1.workHours }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SectionHeader(
                        eyebrow: "돈",
                        title: "그 물건은 당신 삶의 몇 시간인가요?",
                        subtitle: "가계부는 얼마를 썼는지 알려줍니다. memori는 그 돈을 벌기 위해 내준 시간을 알려줍니다."
                    )

                    if monthlyIncome > 0 {
                        calculator
                    } else {
                        incomePrompt
                    }

                    if reclaimedHours > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("되찾은 시간").eyebrow()
                            BigNumber(value: Int(reclaimedHours.rounded()), unit: "시간", size: 56)
                            Text("다시 생각하고 보내준 것들의 노동 시간입니다.").muted()
                        }
                    }

                    if !pending.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("다시 생각하는 중").eyebrow()
                            ForEach(pending) { WishRow(wish: $0) }
                        }
                    }

                    if !decided.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("지난 결정").eyebrow()
                            ForEach(decided) { wish in
                                HStack {
                                    Text(wish.title).font(.mBody).foregroundStyle(Color.mInk)
                                    Spacer()
                                    Text(wish.decision == .bought ? "샀음" : "보내줌").muted()
                                }
                                .contextMenu {
                                    Button("삭제", role: .destructive) { context.delete(wish) }
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.mBackground)
            .sheet(item: $shareCard) { ShareCardSheet(card: $0) }
        }
    }

    // MARK: Calculator

    @ViewBuilder
    private var calculator: some View {
        let hours = price.flatMap { LifeMath.workHours(price: $0, monthlyIncome: monthlyIncome) }

        VStack(alignment: .leading, spacing: 16) {
            TextField("사고 싶은 것", text: $title)
                .font(.mBody)
                .focused($focused)
            Divider()
            TextField("가격 (원)", value: $price, format: .number)
                .font(.mBody)
                .keyboardType(.numberPad)
                .focused($focused)

            if let hours, hours > 0 {
                BigNumber(value: Int(hours.rounded()), unit: "시간", size: 64)
                    .padding(.top, 8)
                Text(note(hours: hours)).muted()

                HStack(spacing: 12) {
                    Button("7일 뒤 다시 묻기") { hold(hours: hours) }
                        .buttonStyle(.memoriPrimary)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    Button {
                        shareCard = ShareCard(
                            eyebrow: "Memento mori",
                            value: Int(hours.rounded()),
                            unit: "시간",
                            caption: "\(title.isEmpty ? "이것" : title)의 가격을 내 노동 시간으로 바꾸면."
                        )
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 52, height: 52)
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.mLine, lineWidth: 1))
                    }
                    .accessibilityLabel("공유하기")
                }
            }
        }
        .card()
    }

    private var incomePrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("먼저, 한 달 실수령액을 알려주세요.")
                .font(.mHeadline)
                .foregroundStyle(Color.mInk)
            Text("가격을 노동 시간으로 바꾸는 데만 씁니다. 기기 밖으로 나가지 않습니다.").muted()
            TextField("월 실수령액 (원)", value: $incomeDraft, format: .number)
                .keyboardType(.numberPad)
                .font(.mBody)
                .padding(.vertical, 8)
            Button("저장") {
                monthlyIncome = incomeDraft ?? 0
                focused = false
            }
            .buttonStyle(.memoriPrimary)
            .disabled((incomeDraft ?? 0) <= 0)
        }
        .card()
    }

    private func note(hours: Double) -> String {
        let days = String(format: "%.1f", hours / 8)
        let share = LifeMath.shareOfWakingLife(hours: hours, age: age, lifeExpectancy: lifeExpectancy)
        return "하루 8시간 기준 \(days)일의 노동. 남은 깨어 있는 시간의 \(Format.percent(share))입니다."
    }

    private func hold(hours: Double) {
        let wish = WishItem(
            title: title.trimmingCharacters(in: .whitespaces),
            price: price ?? 0,
            workHours: hours
        )
        context.insert(wish)
        Reminders.scheduleRevisit(uid: wish.uid, title: wish.title, hours: hours, at: wish.revisitAt)
        title = ""
        price = nil
        focused = false
    }
}

private struct WishRow: View {
    let wish: WishItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(wish.title).font(.mHeadline).foregroundStyle(Color.mInk)
                Spacer()
                Text("\(Int(wish.workHours.rounded()).formatted())시간").muted()
            }
            Text(Format.won(wish.price)).muted()

            if wish.isDue() {
                Text("아직도 \(Int(wish.workHours.rounded()).formatted())시간의 가치가 있나요?")
                    .font(.mBody)
                    .foregroundStyle(Color.mInk)
                    .padding(.top, 4)
                HStack(spacing: 12) {
                    Button("그래도 산다") { decide(.bought) }
                        .buttonStyle(.memoriSecondary)
                    Button("보내준다") { decide(.letGo) }
                        .buttonStyle(.memoriPrimary)
                }
            } else {
                Text("\(Format.day(wish.revisitAt))에 다시 물어볼게요.").muted()
            }
        }
        .card()
    }

    private func decide(_ decision: WishItem.Decision) {
        withAnimation(.smooth) { wish.decision = decision }
        Reminders.cancelRevisit(uid: wish.uid)
    }
}
