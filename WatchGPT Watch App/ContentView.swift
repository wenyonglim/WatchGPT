import SwiftUI

/// Root view that shows the conversation list
struct ContentView: View {
    var body: some View {
        ConversationListView()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Conversation.self, inMemory: true)
}
