import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FurtravelStore
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    @AppStorage("furtravel_notifyEnabled") private var notifyEnabled = true
    @AppStorage("furtravel_reminderEnabled") private var reminderEnabled = false
    @State private var showingResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Notifications", isOn: $notifyEnabled)
                        .accessibilityIdentifier("toggleNotifications")
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                        .accessibilityIdentifier("toggleReminder")
                }
                Section("Subscription") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.primary)
                    } else {
                        Text("Free plan — up to \(FurtravelStore.freeEntryLimit) entries")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restorePurchasesButton")
                }
                Section("Data") {
                    Button("Reset All Data", role: .destructive) {
                        showingResetConfirm = true
                    }
                    .accessibilityIdentifier("resetDataButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/furtravel-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/furtravel-app/terms.html")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("doneSettingsButton")
                }
            }
            .confirmationDialog("Reset all data? This cannot be undone.", isPresented: $showingResetConfirm, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { store.deleteAllData() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
