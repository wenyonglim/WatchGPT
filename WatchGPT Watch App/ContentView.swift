import SwiftUI

/// Root view that shows the conversation list
struct ContentView: View {
    @State private var showAPIKeyView = false

    var body: some View {
        ConversationListView()
            .sheet(isPresented: $showAPIKeyView) {
                NavigationStack {
                    APIKeyView {
                        showAPIKeyView = !KeychainService.hasAPIKey()
                    }
                }
            }
            .onAppear {
                showAPIKeyView = !KeychainService.hasAPIKey()
            }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Conversation.self, inMemory: true)
}
