import SwiftData
import SwiftUI

@main
struct MemoriApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Person.self, WishItem.self])
    }
}

struct RootView: View {
    @AppStorage(Profile.onboardedKey, store: .shared) private var onboarded = false
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if onboarded {
                MainTabs()
            } else {
                OnboardingView()
            }
        }
        .tint(.mInk)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { WidgetSync.publish(context: context) }
        }
    }
}

struct MainTabs: View {
    var body: some View {
        TabView {
            TimeView()
                .tabItem { Label("시간", systemImage: "hourglass") }
            PeopleView()
                .tabItem { Label("사람", systemImage: "person.2") }
            MoneyView()
                .tabItem { Label("돈", systemImage: "wonsign") }
        }
    }
}
