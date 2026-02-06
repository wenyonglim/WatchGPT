import Foundation
import WatchConnectivity

@MainActor
final class CompanionKeyTransferManager: NSObject, ObservableObject {
    @Published var apiKeyInput = ""
    @Published private(set) var statusMessage = "Paste your OpenAI API key, then send it to your watch."

    private(set) var activationState: WCSessionActivationState = .notActivated

    override init() {
        super.init()
        activate()
    }

    func activate() {
        guard WCSession.isSupported() else {
            statusMessage = "WatchConnectivity is unavailable on this iPhone."
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func sendToWatch() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            statusMessage = "Enter a valid API key first."
            return
        }

        let session = WCSession.default
        guard session.activationState == .activated else {
            statusMessage = "Still connecting to Apple Watch. Try again in a moment."
            return
        }
        guard session.isPaired else {
            statusMessage = "No paired Apple Watch found."
            return
        }
        guard session.isWatchAppInstalled else {
            statusMessage = "Install WatchGPT on your watch first."
            return
        }

        let payload: [String: Any] = [
            APIKeyTransferPayload.apiKey: key,
            APIKeyTransferPayload.sentAt: Date().timeIntervalSince1970,
        ]

        do {
            try session.updateApplicationContext(payload)
        } catch {
            statusMessage = "Failed to queue context update: \(error.localizedDescription)"
        }

        session.transferUserInfo(payload)

        guard session.isReachable else {
            statusMessage = "Key queued. It will sync when watch is reachable."
            return
        }

        statusMessage = "Sending key to watch..."
        session.sendMessage(payload) { _ in
            Task { @MainActor in
                self.statusMessage = "API key synced to watch."
            }
        } errorHandler: { error in
            Task { @MainActor in
                self.statusMessage = "Queued, but immediate send failed: \(error.localizedDescription)"
            }
        }
    }
}

extension CompanionKeyTransferManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.activationState = activationState
            if let error {
                self.statusMessage = "Companion activation error: \(error.localizedDescription)"
                return
            }

            switch activationState {
            case .activated:
                self.statusMessage = "Connected. Paste your API key and send."
            case .inactive:
                self.statusMessage = "Companion connection inactive."
            case .notActivated:
                self.statusMessage = "Connecting to Apple Watch..."
            @unknown default:
                self.statusMessage = "Companion connection state unknown."
            }
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            self.statusMessage = "Companion session became inactive."
        }
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            self.statusMessage = "Companion session deactivated. Reconnecting..."
            WCSession.default.activate()
        }
    }
}
