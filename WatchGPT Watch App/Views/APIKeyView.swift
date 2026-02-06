import SwiftUI

struct APIKeyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var apiKeySyncManager: WatchAPIKeySyncManager

    @State private var apiKey: String = KeychainService.getAPIKey() ?? ""
    @State private var errorMessage: String?
    @State private var showKey = false
    @State private var showManualEntry = false

    @AppStorage("nightMode") private var nightMode = false

    let onSaved: (() -> Void)?

    var body: some View {
        List {
            Section {
                Text("Use the iPhone companion app to paste and send your API key.")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))

                Text(apiKeySyncManager.statusMessage)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))

                if let lastReceivedAt = apiKeySyncManager.lastReceivedAt {
                    Text("Last synced: \(lastReceivedAt, style: .time)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                }
            } header: {
                Text("iPhone Sync (Recommended)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }

            Section {
                Toggle(isOn: $showManualEntry) {
                    Text("Type on Watch Instead")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                }
                .tint(Theme.accentColor(nightMode: nightMode))

                if showManualEntry {
                    if showKey {
                        TextField("API Key", text: $apiKey, axis: .vertical)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(.caption, design: .monospaced))
                    } else {
                        SecureField("API Key", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(.caption, design: .monospaced))
                    }

                    Toggle(isOn: $showKey) {
                        Text("Show Key")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                    }
                    .tint(Theme.accentColor(nightMode: nightMode))
                }
            } header: {
                Text("Manual Fallback")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            } footer: {
                Text("Stored securely in Keychain on this device.")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.error)
                }
            }

            Section {
                Button {
                    saveKey()
                } label: {
                    Text("Save")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))
                }
                .buttonStyle(.plain)
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button {
                    deleteKey()
                } label: {
                    Text("Clear Key")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Theme.error)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .background(Theme.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("API Key")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: KeychainService.didChangeNotification)) { _ in
            apiKey = KeychainService.getAPIKey() ?? ""
            errorMessage = nil
            onSaved?()
        }
    }

    private func saveKey() {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try KeychainService.setAPIKey(trimmed)
            errorMessage = nil
            onSaved?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteKey() {
        do {
            try KeychainService.deleteAPIKey()
            apiKey = ""
            errorMessage = nil
            onSaved?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        APIKeyView(onSaved: nil)
            .environmentObject(WatchAPIKeySyncManager())
    }
}
