import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: BadmintonStore
    @Binding var selectedTab: Int
    @State private var showRecordMatch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Total Matches",
                            value: "\(store.totalMatchesCount)",
                            icon: "sportscourt.fill",
                            tint: .blue
                        )
                        MetricCard(
                            title: "Today's Matches",
                            value: "\(store.todaysMatchesCount)",
                            icon: "calendar.badge.clock",
                            tint: .green
                        )
                    }

                    LeaderHighlightCard(
                        badge: "#1 Ranked Player",
                        stat: store.topRankedPlayer,
                        icon: "person.fill.checkmark",
                        tint: .orange
                    )

                    LeaderHighlightCard(
                        badge: "#1 Ranked Team",
                        stat: store.topRankedTeam,
                        icon: "trophy.fill",
                        tint: .purple
                    )

                    HStack(spacing: 12) {
                        Button {
                            showRecordMatch = true
                        } label: {
                            Label("Record Score", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.teams.count < 2)

                        Button {
                            selectedTab = 4
                        } label: {
                            Label("Players & Teams", systemImage: "person.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recent Matches")
                                .font(.headline)
                            Spacer()
                            if !store.matches.isEmpty {
                                Button("See All") { selectedTab = 1 }
                                    .font(.subheadline)
                            }
                        }

                        if store.matches.isEmpty {
                            VStack(spacing: 8) {
                                Text("No completed matches yet.")
                                    .foregroundStyle(.secondary)
                                if store.players.isEmpty {
                                    Button("Load Sample Data") {
                                        store.loadSampleData()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ForEach(store.matches.prefix(4)) { match in
                                MatchRowCard(match: match)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Badminton Doubles")
            .sheet(isPresented: $showRecordMatch) {
                RecordMatchSheet()
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct LeaderHighlightCard: View {
    let badge: String
    let stat: StatSummary?
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(badge.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(tint)

                if let stat {
                    Text(stat.name)
                        .font(.title3.bold())
                    Text("\(stat.wins)W - \(stat.losses)L  •  \(Int(stat.winRate * 100))% Win Rate  •  Diff \(stat.pointDiff >= 0 ? "+" : "")\(stat.pointDiff)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No rankings yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
