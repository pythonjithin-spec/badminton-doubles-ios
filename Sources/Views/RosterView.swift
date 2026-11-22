import SwiftUI

struct RosterView: View {
    @EnvironmentObject var store: BadmintonStore
    @State private var segment = 0
    @State private var showAddPlayer = false
    @State private var showAddTeam = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Roster", selection: $segment) {
                    Text("Players (\(store.players.count))").tag(0)
                    Text("Teams (\(store.teams.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if segment == 0 {
                    List {
                        if store.players.isEmpty {
                            Text("Tap + to add your first player.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(store.players) { player in
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundStyle(.blue)
                                    Text(player.name)
                                }
                            }
                            .onDelete(perform: store.deletePlayers)
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    List {
                        if store.teams.isEmpty {
                            Text(store.players.count < 2
                                 ? "Add at least 2 players before creating a doubles team."
                                 : "Tap + to create a doubles team.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(store.teams) { team in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(team.name)
                                        .font(.headline)
                                    Text(store.teamMembersSubtitle(for: team))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .onDelete(perform: store.deleteTeams)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Roster")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if segment == 0 {
                            showAddPlayer = true
                        } else {
                            showAddTeam = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(segment == 1 && store.players.count < 2)
                }
            }
            .sheet(isPresented: $showAddPlayer) {
                AddPlayerSheet()
            }
            .sheet(isPresented: $showAddTeam) {
                AddTeamSheet()
            }
        }
    }
}

struct AddPlayerSheet: View {
    @EnvironmentObject var store: BadmintonStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Player Name", text: $name)
                    .textInputAutocapitalization(.words)
            }
            .navigationTitle("New Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addPlayer(name: name)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddTeamSheet: View {
    @EnvironmentObject var store: BadmintonStore
    @Environment(\.dismiss) var dismiss

    @State private var teamName = ""
    @State private var player1ID: UUID?
    @State private var player2ID: UUID?

    private var canCreate: Bool {
        guard let p1 = player1ID, let p2 = player2ID else { return false }
        return p1 != p2
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Details") {
                    TextField("Team Name (optional)", text: $teamName)
                        .textInputAutocapitalization(.words)
                }

                Section("Select Doubles Partners") {
                    Picker("Player 1", selection: $player1ID) {
                        Text("Choose Player").tag(nil as UUID?)
                        ForEach(store.players) { player in
                            Text(player.name).tag(player.id as UUID?)
                        }
                    }

                    Picker("Player 2", selection: $player2ID) {
                        Text("Choose Player").tag(nil as UUID?)
                        ForEach(store.players) { player in
                            Text(player.name).tag(player.id as UUID?)
                        }
                    }

                    if player1ID != nil && player1ID == player2ID {
                        Text("Select two different players for a doubles team.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Doubles Team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if let p1 = player1ID, let p2 = player2ID {
                            store.addTeam(name: teamName, player1ID: p1, player2ID: p2)
                            dismiss()
                        }
                    }
                    .disabled(!canCreate)
                }
            }
            .onAppear {
                if player1ID == nil { player1ID = store.players.first?.id }
                if player2ID == nil, store.players.count > 1 { player2ID = store.players[1].id }
            }
        }
    }
}
