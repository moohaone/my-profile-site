import SwiftUI

/// The one big number on every screen.
struct BigNumber: View {
    let value: Int
    let unit: String
    var size: CGFloat = 88

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(value.formatted())
                .font(.mNumber(size))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(value)))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(unit)
                .font(.system(size: size * 0.28))
                .foregroundStyle(Color.mMuted)
        }
        .foregroundStyle(Color.mInk)
        .animation(.smooth(duration: 0.6), value: value)
        .accessibilityElement(children: .combine)
    }
}

/// Header block shared by the three tabs.
struct SectionHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow).eyebrow()
            Text(title)
                .font(.mTitle)
                .foregroundStyle(Color.mInk)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.mBody)
                    .foregroundStyle(Color.mMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// A life in weeks: one dot per week, one row per year.
struct LifeGrid: View {
    let weeksLived: Int
    let totalWeeks: Int
    private let columns = 52

    var body: some View {
        let rows = max(1, Int((Double(totalWeeks) / Double(columns)).rounded(.up)))
        Canvas { context, size in
            let cell = size.width / CGFloat(columns)
            let radius = max(0.8, cell * 0.3)
            for week in 0..<totalWeeks {
                let x = CGFloat(week % columns) * cell + cell / 2
                let y = CGFloat(week / columns) * cell + cell / 2
                let dot = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: dot), with: .color(week < weeksLived ? .mInk : .mWalnut))
            }
        }
        .aspectRatio(CGFloat(columns) / CGFloat(rows), contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("한 칸이 한 주인 인생 달력. \(weeksLived.formatted())주를 지나왔고 \(max(0, totalWeeks - weeksLived).formatted())주가 남았습니다.")
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mHeadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(Color.mBackground)
            .background(Color.mInk)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mHeadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(Color.mInk)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.mLine, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var memoriPrimary: PrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var memoriSecondary: SecondaryButtonStyle { .init() }
}

enum Format {
    /// 0.000235 → "0.02%", matching the landing page.
    static func percent(_ fraction: Double) -> String {
        let value = fraction * 100
        return String(format: value < 0.01 ? "%.3f%%" : "%.2f%%", value)
    }

    static func won(_ amount: Int) -> String {
        "\(amount.formatted())원"
    }

    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "ko_KR")).month().day().weekday(.abbreviated))
    }
}
