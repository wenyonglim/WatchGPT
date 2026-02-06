import SwiftUI
import SwiftData

/// WatchGPT - An Apple Watch app for ChatGPT conversations
/// with text input and audio playback via OpenAI APIs
@main
struct WatchGPTApp: App {
    @StateObject private var apiKeySyncManager = WatchAPIKeySyncManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(apiKeySyncManager)
        }
        .modelContainer(for: Conversation.self)
    }
}
