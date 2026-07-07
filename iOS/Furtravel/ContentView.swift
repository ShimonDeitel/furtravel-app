import SwiftUI

struct EntryDraft {
    var date: Date = Date()
    var destination: String = ""
    var notes: String = ""
}

struct ContentView: View {
    @EnvironmentObject var store: FurtravelStore
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingID: UUID?
    @State private var draft = EntryDraft()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    if store.entries.isEmpty {
                        Text("No entries yet. Tap + to add your first one.")
                            .foregroundStyle(Theme.textSecondary)
                            .listRowBackground(Theme.background)
                    }
                    ForEach(store.entries) { entry in
                        Button {
                            draft = EntryDraft(date: entry.date, destination: entry.destination, notes: entry.notes)
                            editingID = entry.id
                            showingAdd = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(entry.destination)")
                                    .font(Theme.bodyFont(17))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(Theme.bodyFont(13))
                                    .foregroundStyle(Theme.textSecondary)
                                if !"\(entry.notes)".isEmpty {
                                    Text("\(entry.notes)")
                                        .font(Theme.bodyFont(13))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                        .accessibilityIdentifier("entryRow_\(entry.id)")
                    }
                    .onDelete { offsets in store.delete(at: offsets) }
                    .listRowBackground(Theme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Furtravel")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddEntry(isPro: purchases.isPro) {
                            draft = EntryDraft()
                            editingID = nil
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntrySheet(draft: $draft, isEditing: editingID != nil) {
                    if let id = editingID {
                        store.updateEntry(id, date: draft.date, destination: draft.destination, notes: draft.notes)
                    } else {
                        store.addEntry(date: draft.date, destination: draft.destination, notes: draft.notes, isPro: purchases.isPro)
                    }
                    showingAdd = false
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct AddEntrySheet: View {
    @Binding var draft: EntryDraft
    var isEditing: Bool
    var onSave: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $draft.date)
                    TextField("Destination", text: $draft.destination, axis: .vertical)
                    .accessibilityIdentifier("field_destination")
                        .focused($isFocused)
                    TextField("How they handled it", text: $draft.notes, axis: .vertical)
                    .accessibilityIdentifier("field_notes")
                        .focused($isFocused)
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onSave() }
                        .accessibilityIdentifier("cancelEntryButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .accessibilityIdentifier("saveEntryButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }
}
