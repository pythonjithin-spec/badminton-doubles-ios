import Foundation

struct Player: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var createdAt = Date()
}

struct Team: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var player1ID: UUID
    var player2ID: UUID
    var createdAt = Date()

    func contains(playerID: UUID) -> Bool {
        player1ID == playerID || player2ID == playerID
    }

    func partnerID(for playerID: UUID) -> UUID? {
        if player1ID == playerID { return player2ID }
        if player2ID == playerID { return player1ID }
        return nil
    }
}

struct GameSet: Identifiable, Codable, Hashable {
    var id = UUID()
    var teamAScore: Int
    var teamBScore: Int
}

struct MatchRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var teamAID: UUID
    var teamBID: UUID
    var sets: [GameSet]

    var teamASetsWon: Int {
        sets.filter { $0.teamAScore > $0.teamBScore }.count
    }

    var teamBSetsWon: Int {
        sets.filter { $0.teamBScore > $0.teamAScore }.count
    }

    var teamATotalPoints: Int {
        sets.reduce(0) { $0 + $1.teamAScore }
    }

    var teamBTotalPoints: Int {
        sets.reduce(0) { $0 + $1.teamBScore }
    }

    var winnerTeamID: UUID? {
        if teamASetsWon > teamBSetsWon { return teamAID }
        if teamBSetsWon > teamASetsWon { return teamBID }
        return nil
    }

    var scoreSummary: String {
        sets.map { "\($0.teamAScore)-\($0.teamBScore)" }.joined(separator: ", ")
    }
}

struct StatSummary: Identifiable {
    let id: UUID
    let name: String
    let subtitle: String
    let matchesPlayed: Int
    let wins: Int
    let losses: Int
    let pointsFor: Int
    let pointsAgainst: Int
    let recentForm: [Bool]

    var winRate: Double {
        matchesPlayed == 0 ? 0 : Double(wins) / Double(matchesPlayed)
    }

    var pointDiff: Int {
        pointsFor - pointsAgainst
    }
}

struct PartnerStat: Identifiable {
    let id: UUID
    let partnerName: String
    let played: Int
    let wins: Int

    var winRate: Double {
        played == 0 ? 0 : Double(wins) / Double(played)
    }
}
