import SwiftUI

/// One number, one line, rendered as an image worth posting.
struct ShareCard: Identifiable {
    let id = UUID()
    let eyebrow: String
    let value: Int
    let unit: String
    let caption: String
}

struct ShareCardView: View {
    let card: ShareCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.eyebrow).eyebrow()
            Spacer()
            BigNumber(value: card.value, unit: card.unit, size: 96)
            Text(card.caption)
                .font(.mBody)
                .foregroundStyle(Color.mMuted)
                .padding(.top, 12)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text("memori")
                .font(.system(size: 13, weight: .medium))
                .tracking(3.6)
                .foregroundStyle(Color.mInk)
        }
        .padding(32)
        .frame(width: 360, height: 450, alignment: .leading)
        .background(Color.mBackground)
    }
}

struct ShareCardSheet: View {
    let card: ShareCard
    @Environment(\.dismiss) private var dismiss
    @State private var image: Image?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ShareCardView(card: card)
                    .environment(\.colorScheme, .light)
                    .scaleEffect(0.85)
                    .frame(width: 306, height: 383)
                    .overlay(Rectangle().stroke(Color.mLine, lineWidth: 1))

                if let image {
                    ShareLink(item: image, preview: SharePreview(card.caption, image: image)) {
                        Text("공유하기")
                    }
                    .buttonStyle(.memoriPrimary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .onAppear { render() }
        }
        .presentationDetents([.large])
    }

    @MainActor
    private func render() {
        let renderer = ImageRenderer(content: ShareCardView(card: card).environment(\.colorScheme, .light))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            image = Image(uiImage: uiImage)
        }
    }
}
