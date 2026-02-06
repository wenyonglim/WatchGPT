import Foundation
import WatchConnectivity

@MainActor
final class WatchAPIKeySyncManager: NSObject, ObservableObject {
    @Published private(set) var statusMessage = "Open the iPhone companion app to send your API key."
    @Published private(set) var lastReceivedAt: Date?

    private(set) var activationState: WCSessionActivationState = .notActivated

    override init() {
        super.init()
        activate()
    }

    func activate() {
        guard WCSession.isSupported() else {
            statusMessage = "WatchConnectivity is unavailable on this device."
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func savePayload(_ payload: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard let rawKey = payload[APIKeyTransferPayload.apiKey] as? String else {
            statusMessage = "Received payload missing API key."
            replyHandler?(["ok": false, "error": "missing_api_key"])
            return
        }

        let key = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            statusMessage = "Received an empty API key."
            replyHandler?(["ok": false, "error": "empty_api_key"])
            return
        }

        do {
            try KeychainService.setAPIKey(key)
            lastReceivedAt = Date()
            statusMessage = "API key synced from iPhone."
            replyHandler?(["ok": true])
        } catch {
            statusMessage = "Failed to save key: \(error.localizedDescription)"
            replyHandler?(["ok": false, "error": "save_failed"])
        }
    }
}

extension WatchAPIKeySyncManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.activationState = activationState
            if let error {
                self.statusMessage = "Companion connection error: \(error.localizedDescription)"
                return
            }

            switch activationState {
            case .activated:
                self.statusMessage = "Companion connection ready."
            case .inactive:
                self.statusMessage = "Companion connection inactive."
            case .notActivated:
                self.statusMessage = "Connecting to companion app..."
            @unknown default:
                self.statusMessage = "Companion connection state unknown."
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.savePayload(message)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Task { @MainActor in
            self.savePayload(message, replyHandler: replyHandler)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            self.savePayload(userInfo)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.savePayload(applicationContext)
        }
    }
}
