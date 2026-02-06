import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var manager = CompanionKeyTransferManager()

    var body: some View {
        NavigationStack {
            Form {
                Section("API Key") {
                    SecureField("sk-...", text: $manager.apiKeyInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.footnote, design: .monospaced))

                    Button("Paste from Clipboard") {
                        if let text = UIPasteboard.general.string {
                            manager.apiKeyInput = text
                        }
                    }

                    Button("Send to Apple Watch") {
                        manager.sendToWatch()
                    }
                    .disabled(manager.apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Status") {
                    Text(manager.statusMessage)
                        .font(.footnote)
                }

                Section("Privacy") {
                    Text("This key is sent to your watch and stored there in Keychain. The iPhone app only keeps it in memory while this screen is open.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("WatchGPT Setup")
        }
    }
}

#Preview {
    ContentView()
}
