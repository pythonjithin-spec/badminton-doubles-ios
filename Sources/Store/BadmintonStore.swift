import Foundation
import SwiftUI

final class BadmintonStore: ObservableObject {
    @Published var players: [Player] = []
    @Published var teams: [Team] = []
    @Published var matches: [MatchRecord] = []

    private let storageKey = "badminton_doubles_data_v1"

    private struct PersistedData: Codable {
        var players: [Player]
        var teams: [Team]
        var matches: [MatchRecord]
    }

    init() {
        load()
    }

    // MARK: - Persistence

    private func save() {
        let payload = PersistedData(players: players, teams: teams, matches: matches)
        if let encoded = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PersistedData.self, from: data) else {
            return
        }
        players = decoded.players
        teams = decoded.teams
        matches = decoded.matches
    }

    // MARK: - CRUD Operations

    func addPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        players.append(Player(name: trimmed))
        save()
    }

    func deletePlayers(at offsets: IndexSet) {
        let idsToRemove = Set(offsets.map { players[$0].id })
        players.remove(atOffsets: offsets)
        let removedTeamIDs = Set(teams.filter {
            idsToRemove.contains($0.player1ID) || idsToRemove.contains($0.player2ID)
        }.map(\.id))
        teams.removeAll { removedTeamIDs.contains($0.id) }
        matches.removeAll { removedTeamIDs.contains($0.teamAID) || removedTeamIDs.contains($0.teamBID) }
        save()
    }

    func addTeam(name: String, player1ID: UUID, player2ID: UUID) {
        guard player1ID != player2ID else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty
            ? "\(playerName(for: player1ID)) & \(playerName(for: player2ID))"
            : trimmed
        teams.append(Team(name: finalName, player1ID: player1ID, player2ID: player2ID))
        save()
    }

    func deleteTeams(at offsets: IndexSet) {
        let removedTeamIDs = Set(offsets.map { teams[$0].id })
        teams.remove(atOffsets: offsets)
        matches.removeAll { removedTeamIDs.contains($0.teamAID) || removedTeamIDs.contains($0.teamBID) }
        save()
    }

    func addMatch(teamAID: UUID, teamBID: UUID, sets: [GameSet], date: Date) {
        let match = MatchRecord(date: date, teamAID: teamAID, teamBID: teamBID, sets: sets)
        matches.insert(match, at: 0)
        matches.sort { $0.date > $1.date }
        save()
    }

    func deleteMatches(at offsets: IndexSet) {
        matches.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Lookups

    func playerName(for id: UUID) -> String {
        players.first(where: { $0.id == id })?.name ?? "Unknown Player"
    }

    func team(for id: UUID) -> Team? {
        teams.first(where: { $0.id == id })
    }

    func teamName(for id: UUID) -> String {
        team(for: id)?.name ?? "Unknown Team"
    }

    func teamMembersSubtitle(for team: Team) -> String {
        "\(playerName(for: team.player1ID)) & \(playerName(for: team.player2ID))"
    }

    // MARK: - Overall Home Metrics

    var totalMatchesCount: Int {
        matches.count
    }

    var todaysMatchesCount: Int {
        matches.filter { Calendar.current.isDateInToday($0.date) }.count
    }

    var topRankedPlayer: StatSummary? {
        playerRankings().first(where: { $0.matchesPlayed > 0 })
    }

    var topRankedTeam: StatSummary? {
        teamRankings().first(where: { $0.matchesPlayed > 0 })
    }

    // MARK: - Rankings & Statistics

    func teamRankings() -> [StatSummary] {
        let sortedMatches = matches.sorted { $0.date > $1.date }

        let stats: [StatSummary] = teams.map { team in
            var played = 0
            var wins = 0
            var pointsFor = 0
            var pointsAgainst = 0
            var form: [Bool] = []

            for match in sortedMatches {
                if match.teamAID == team.id {
                    played += 1
                    pointsFor += match.teamATotalPoints
                    pointsAgainst += match.teamBTotalPoints
                    let won = match.winnerTeamID == team.id
                    if won { wins += 1 }
                    if form.count < 5 { form.append(won) }
                } else if match.teamBID == team.id {
                    played += 1
                    pointsFor += match.teamBTotalPoints
                    pointsAgainst += match.teamATotalPoints
                    let won = match.winnerTeamID == team.id
                    if won { wins += 1 }
                    if form.count < 5 { form.append(won) }
                }
            }

            return StatSummary(
                id: team.id,
                name: team.name,
                subtitle: teamMembersSubtitle(for: team),
                matchesPlayed: played,
                wins: wins,
                losses: played - wins,
                pointsFor: pointsFor,
                pointsAgainst: pointsAgainst,
                recentForm: form
            )
        }

        return sortRankings(stats)
    }

    func playerRankings() -> [StatSummary] {
        let sortedMatches = matches.sorted { $0.date > $1.date }
        let teamMap = Dictionary(uniqueKeysWithValues: teams.map { ($0.id, $0) })

        let stats: [StatSummary] = players.map { player in
            var played = 0
            var wins = 0
            var pointsFor = 0
            var pointsAgainst = 0
            var form: [Bool] = []

            for match in sortedMatches {
                let teamA = teamMap[match.teamAID]
                let teamB = teamMap[match.teamBID]

                if teamA?.contains(playerID: player.id) == true {
                    played += 1
                    pointsFor += match.teamATotalPoints
                    pointsAgainst += match.teamBTotalPoints
                    let won = match.winnerTeamID == match.teamAID
                    if won { wins += 1 }
                    if form.count < 5 { form.append(won) }
                } else if teamB?.contains(playerID: player.id) == true {
                    played += 1
                    pointsFor += match.teamBTotalPoints
                    pointsAgainst += match.teamATotalPoints
                    let won = match.winnerTeamID == match.teamBID
                    if won { wins += 1 }
                    if form.count < 5 { form.append(won) }
                }
            }

            let teamCount = teams.filter { $0.contains(playerID: player.id) }.count
            return StatSummary(
                id: player.id,
                name: player.name,
                subtitle: "\(teamCount) team\(teamCount == 1 ? "" : "s")",
                matchesPlayed: played,
                wins: wins,
                losses: played - wins,
                pointsFor: pointsFor,
                pointsAgainst: pointsAgainst,
                recentForm: form
            )
        }

        return sortRankings(stats)
    }

    func stats(forPlayerID id: UUID) -> StatSummary? {
        playerRankings().first(where: { $0.id == id })
    }

    func matches(forPlayerID id: UUID) -> [MatchRecord] {
        matches.filter { match in
            let inA = team(for: match.teamAID)?.contains(playerID: id) ?? false
            let inB = team(for: match.teamBID)?.contains(playerID: id) ?? false
            return inA || inB
        }
    }

    func partnerBreakdown(forPlayerID id: UUID) -> [PartnerStat] {
        var tracker: [UUID: (played: Int, wins: Int)] = [:]

        for match in matches {
            if let teamA = team(for: match.teamAID), let partner = teamA.partnerID(for: id) {
                var entry = tracker[partner, default: (0, 0)]
                entry.played += 1
                if match.winnerTeamID == teamA.id { entry.wins += 1 }
                tracker[partner] = entry
            } else if let teamB = team(for: match.teamBID), let partner = teamB.partnerID(for: id) {
                var entry = tracker[partner, default: (0, 0)]
                entry.played += 1
                if match.winnerTeamID == teamB.id { entry.wins += 1 }
                tracker[partner] = entry
            }
        }

        return tracker.map { partnerID, data in
            PartnerStat(
                id: partnerID,
                partnerName: playerName(for: partnerID),
                played: data.played,
                wins: data.wins
            )
        }
        .sorted { $0.wins > $1.wins || ($0.wins == $1.wins && $0.played > $1.played) }
    }

    private func sortRankings(_ list: [StatSummary]) -> [StatSummary] {
        list.sorted { lhs, rhs in
            if lhs.wins != rhs.wins { return lhs.wins > rhs.wins }
            if lhs.winRate != rhs.winRate { return lhs.winRate > rhs.winRate }
            if lhs.pointDiff != rhs.pointDiff { return lhs.pointDiff > rhs.pointDiff }
            if lhs.matchesPlayed != rhs.matchesPlayed { return lhs.matchesPlayed > rhs.matchesPlayed }
            return lhs.name < rhs.name
        }
    }

    // MARK: - Sample Data

    func loadSampleData() {
        let p1 = Player(name: "Arjun")
        let p2 = Player(name: "Rohan")
        let p3 = Player(name: "Karthik")
        let p4 = Player(name: "Vikram")
        let p5 = Player(name: "Ananya")
        let p6 = Player(name: "Meera")

        let t1 = Team(name: "Smash Bros", player1ID: p1.id, player2ID: p2.id)
        let t2 = Team(name: "Net Ninjas", player1ID: p3.id, player2ID: p4.id)
        let t3 = Team(name: "Shuttle Queens", player1ID: p5.id, player2ID: p6.id)
        let t4 = Team(name: "Drop Shotters", player1ID: p1.id, player2ID: p5.id)

        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now

        let sampleMatches = [
            MatchRecord(
                date: now,
                teamAID: t1.id,
                teamBID: t2.id,
                sets: [GameSet(teamAScore: 21, teamBScore: 17), GameSet(teamAScore: 21, teamBScore: 18)]
            ),
            MatchRecord(
                date: now.addingTimeInterval(-3600),
                teamAID: t3.id,
                teamBID: t2.id,
                sets: [
                    GameSet(teamAScore: 19, teamBScore: 21),
                    GameSet(teamAScore: 21, teamBScore: 15),
                    GameSet(teamAScore: 21, teamBScore: 16)
                ]
            ),
            MatchRecord(
                date: yesterday,
                teamAID: t4.id,
                teamBID: t2.id,
                sets: [GameSet(teamAScore: 21, teamBScore: 14)]
            )
        ]

        players = [p1, p2, p3, p4, p5, p6]
        teams = [t1, t2, t3, t4]
        matches = sampleMatches
        save()
    }
}
