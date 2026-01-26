import SwiftUI
import SwiftData

/// Home screen showing list of saved conversations
struct ConversationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    @State private var selectedConversation: Conversation?
    @State private var showSettings = false
    @State private var showModePicker = false
    @AppStorage("nightMode") private var nightMode = false

    var body: some View {
        NavigationStack {
            Group {
                if conversations.isEmpty {
                    emptyState
                } else {
                    conversationList
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Chats")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                    }
                }
            }
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showModePicker) {
                ModePickerSheet { mode in
                    createNewConversation(mode: mode)
                }
            }
        }
        .tint(Theme.accentColor(nightMode: nightMode))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No conversations yet")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))

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
            showModePicker = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                Text("New Chat")
                    .font(.system(.body, design: .rounded))
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedConversation)
    }

    // MARK: - Actions

    private func createNewConversation(mode: AssistantMode) {
        let conversation = Conversation(mode: mode.rawValue)
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
    @AppStorage("nightMode") private var nightMode = false

    private var mode: AssistantMode {
        AssistantMode(rawValue: conversation.mode) ?? .sbr
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: mode.icon)
                .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                .font(.system(.caption))

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))
                    .lineLimit(1)

                Text(conversation.previewTimestamp)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Mode Picker Sheet

private struct ModePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (AssistantMode) -> Void
    @AppStorage("nightMode") private var nightMode = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Choose Mode")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))

                ForEach(AssistantMode.allCases) { mode in
                    Button {
                        dismiss()
                        onSelect(mode)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: mode.icon)
                                .font(.system(.title3))
                                .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.displayName)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))

                                Text(mode.description)
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Theme.userBubbleColor(nightMode: nightMode))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Theme.background)
    }
}

#Preview {
    ConversationListView()
        .modelContainer(for: Conversation.self, inMemory: true)
}
