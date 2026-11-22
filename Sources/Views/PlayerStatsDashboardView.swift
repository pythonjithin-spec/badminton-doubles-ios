import SwiftUI

struct PlayerStatsDashboardView: View {
    @EnvironmentObject var store: BadmintonStore
    @State private var selectedPlayerID: UUID?

    var body: some View {
        NavigationStack {
            Group {
                if store.players.isEmpty {
                    Text("Add players in the Roster tab to view player statistics.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Player")
                                    .font(.headline)
                                Spacer()
                                Picker("Select Player", selection: $selectedPlayerID) {
                                    ForEach(store.players) { player in
                                        Text(player.name).tag(player.id as UUID?)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            if let pid = selectedPlayerID ?? store.players.first?.id,
                               let stat = store.stats(forPlayerID: pid) {

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    MetricCard(title: "Matches Played", value: "\(stat.matchesPlayed)", icon: "sportscourt", tint: .blue)
                                    MetricCard(title: "Win Rate", value: "\(Int(stat.winRate * 100))%", icon: "percent", tint: .green)
                                    MetricCard(title: "Wins / Losses", value: "\(stat.wins) - \(stat.losses)", icon: "checkmark.seal.fill", tint: .orange)
                                    MetricCard(title: "Point Differential", value: "\(stat.pointDiff >= 0 ? "+" : "")\(stat.pointDiff)", icon: "arrow.up.arrow.down", tint: stat.pointDiff >= 0 ? .teal : .red)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Recent Form (Last 5)")
                                        .font(.headline)
                                    if stat.recentForm.isEmpty {
                                        Text("No matches played yet.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        HStack(spacing: 8) {
                                            ForEach(Array(stat.recentForm.enumerated()), id: \.offset) { _, won in
                                                Text(won ? "W" : "L")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                                    .frame(width: 30, height: 30)
                                                    .background(won ? Color.green : Color.red)
                                                    .clipShape(Circle())
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Points Breakdown")
                                        .font(.headline)
                                    HStack {
                                        Text("Points Scored: \(stat.pointsFor)")
                                        Spacer()
                                        Text("Points Conceded: \(stat.pointsAgainst)")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                let partners = store.partnerBreakdown(forPlayerID: pid)
                                if !partners.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Partner Chemistry")
                                            .font(.headline)
                                        ForEach(partners) { partner in
                                            HStack {
                                                Text(partner.partnerName)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                Text("\(partner.wins)/\(partner.played) wins (\(Int(partner.winRate * 100))%)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                let history = store.matches(forPlayerID: pid)
                                if !history.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Match History")
                                            .font(.headline)
                                        ForEach(history) { match in
                                            MatchRowCard(match: match)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationTitle("Player Stats")
            .onAppear {
                if selectedPlayerID == nil {
                    selectedPlayerID = store.players.first?.id
                }
            }
        }
    }
}
