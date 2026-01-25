import SwiftUI
import SwiftData

/// Home screen showing list of saved conversations
struct ConversationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            Group {
                if conversations.isEmpty {
                    emptyState
                } else {
                    conversationList
                }
            }
            .navigationTitle("Chats")
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No conversations yet")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.secondaryText)

            newChatButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }

    // MARK: - Conversation List

    private var conversationList: some View {
        List {
            Section {
                newChatButton
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(conversations) { conversation in
                    ConversationRow(conversation: conversation)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedConversation = conversation
                        }
                }
                .onDelete(perform: deleteConversations)
            }
        }
        .listStyle(.plain)
        .background(Theme.background)
        .scrollContentBackground(.hidden)
    }

    // MARK: - New Chat Button

    private var newChatButton: some View {
        Button {
            createNewConversation()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.accent)
                Text("New Chat")
                    .font(.system(.body, design: .rounded))
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedConversation)
    }

    // MARK: - Actions

    private func createNewConversation() {
        let conversation = Conversation()
        modelContext.insert(conversation)
        selectedConversation = conversation
    }

    private func deleteConversations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(conversations[index])
        }
    }
}

// MARK: - Conversation Row

private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)

            Text(conversation.previewTimestamp)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConversationListView()
        .modelContainer(for: Conversation.self, inMemory: true)
}
