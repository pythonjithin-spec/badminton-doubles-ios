import SwiftUI

struct RankingsDashboardView: View {
    @EnvironmentObject var store: BadmintonStore
    @State private var mode = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Ranking Type", selection: $mode) {
                    Text("Players").tag(0)
                    Text("Teams").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                let rankings = mode == 0 ? store.playerRankings() : store.teamRankings()

                if rankings.isEmpty {
                    Spacer()
                    Text(mode == 0 ? "No players added yet." : "No teams added yet.")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(Array(rankings.enumerated()), id: \.element.id) { index, item in
                            RankingRow(rank: index + 1, item: item)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Rankings")
        }
    }
}

struct RankingRow: View {
    let rank: Int
    let item: StatSummary

    private var badgeColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(rank <= 3 ? badgeColor.opacity(0.2) : Color(uiColor: .tertiarySystemFill))
                    .frame(width: 34, height: 34)
                Text("#\(rank)")
                    .font(.caption.bold())
                    .foregroundStyle(rank <= 3 ? badgeColor : .primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.wins)W - \(item.losses)L")
                    .font(.subheadline.bold().monospacedDigit())
                Text("\(Int(item.winRate * 100))%  •  \(item.pointDiff >= 0 ? "+" : "")\(item.pointDiff) pts")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
