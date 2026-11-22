import SwiftUI

@main
struct BadmintonDoublesApp: App {
    @StateObject private var store = BadmintonStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "figure.badminton")
                }
                .tag(1)

            PlayerStatsDashboardView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            RankingsDashboardView()
                .tabItem {
                    Label("Rankings", systemImage: "trophy.fill")
                }
                .tag(3)

            RosterView()
                .tabItem {
                    Label("Roster", systemImage: "person.2.fill")
                }
                .tag(4)
        }
    }
}
