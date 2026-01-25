import SwiftUI
import SwiftData

/// WatchGPT - An Apple Watch app for ChatGPT conversations
/// with text input and audio playback via OpenAI APIs
@main
struct WatchGPTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Conversation.self)
    }
}
