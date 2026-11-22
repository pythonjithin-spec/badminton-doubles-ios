import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var store: BadmintonStore
    @State private var showRecordSheet = false

    var body: some View {
        NavigationStack {
            List {
                if store.matches.isEmpty {
                    Text("Tap + to log a completed doubles match.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.matches) { match in
                        MatchRowCard(match: match)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: store.deleteMatches)
                }
            }
            .listStyle(.plain)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Matches")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showRecordSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(store.teams.count < 2)
                }
            }
            .sheet(isPresented: $showRecordSheet) {
                RecordMatchSheet()
            }
        }
    }
}

struct MatchRowCard: View {
    @EnvironmentObject var store: BadmintonStore
    let match: MatchRecord

    var body: some View {
        let teamAName = store.teamName(for: match.teamAID)
        let teamBName = store.teamName(for: match.teamBID)
        let aWon = match.winnerTeamID == match.teamAID
        let bWon = match.winnerTeamID == match.teamBID

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(match.scoreSummary)
                    .font(.caption.monospacedDigit().bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(teamAName)
                            .fontWeight(aWon ? .bold : .regular)
                        if aWon {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    HStack {
                        Text(teamBName)
                            .fontWeight(bWon ? .bold : .regular)
                        if bWon {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(match.teamASetsWon)")
                        .fontWeight(aWon ? .bold : .regular)
                    Text("\(match.teamBSetsWon)")
                        .fontWeight(bWon ? .bold : .regular)
                }
                .font(.headline.monospacedDigit())
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RecordMatchSheet: View {
    @EnvironmentObject var store: BadmintonStore
    @Environment(\.dismiss) var dismiss

    @State private var teamAID: UUID?
    @State private var teamBID: UUID?
    @State private var matchDate = Date()
    @State private var sets: [GameSet] = [GameSet(teamAScore: 21, teamBScore: 15)]

    private var hasOverlappingPlayers: Bool {
        guard let aID = teamAID, let bID = teamBID,
              let teamA = store.team(for: aID),
              let teamB = store.team(for: bID) else { return false }
        let setA: Set<UUID> = [teamA.player1ID, teamA.player2ID]
        let setB: Set<UUID> = [teamB.player1ID, teamB.player2ID]
        return !setA.isDisjoint(with: setB)
    }

    private var setsHaveValidWinner: Bool {
        let allDecided = sets.allSatisfy { $0.teamAScore != $0.teamBScore && $0.teamAScore >= 0 && $0.teamBScore >= 0 }
        let aWins = sets.filter { $0.teamAScore > $0.teamBScore }.count
        let bWins = sets.filter { $0.teamBScore > $0.teamAScore }.count
        return allDecided && aWins != bWins
    }

    private var canSave: Bool {
        teamAID != nil && teamBID != nil && teamAID != teamBID && !hasOverlappingPlayers && setsHaveValidWinner
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Teams") {
                    Picker("Team A", selection: $teamAID) {
                        Text("Select Team").tag(nil as UUID?)
                        ForEach(store.teams) { team in
                            Text(team.name).tag(team.id as UUID?)
                        }
                    }

                    Picker("Team B", selection: $teamBID) {
                        Text("Select Team").tag(nil as UUID?)
                        ForEach(store.teams) { team in
                            Text(team.name).tag(team.id as UUID?)
                        }
                    }

                    if teamAID != nil && teamAID == teamBID {
                        Text("Please select two different teams.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if hasOverlappingPlayers {
                        Text("A player cannot play on both teams in the same match.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    DatePicker("Completed At", selection: $matchDate)
                }

                Section("Final Set Scores") {
                    ForEach($sets) { $gameSet in
                        let index = sets.firstIndex(where: { $0.id == gameSet.id }) ?? 0
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Set \(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Stepper("Team A: \(gameSet.teamAScore)", value: $gameSet.teamAScore, in: 0...30)
                            Stepper("Team B: \(gameSet.teamBScore)", value: $gameSet.teamBScore, in: 0...30)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        if sets.count > 1 {
                            sets.remove(atOffsets: offsets)
                        }
                    }

                    if sets.count < 3 {
                        Button("Add Set \(sets.count + 1)") {
                            sets.append(GameSet(teamAScore: 21, teamBScore: 18))
                        }
                    }

                    if !setsHaveValidWinner {
                        Text("Each set must have a winner and overall sets cannot be tied.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Log Completed Match")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let aID = teamAID, let bID = teamBID {
                            store.addMatch(teamAID: aID, teamBID: bID, sets: sets, date: matchDate)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if teamAID == nil { teamAID = store.teams.first?.id }
                if teamBID == nil, store.teams.count > 1 { teamBID = store.teams[1].id }
            }
        }
    }
}
