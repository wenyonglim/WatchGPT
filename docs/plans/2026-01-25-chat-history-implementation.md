# Chat History Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add persistent chat history with conversation list, selection, and deletion.

**Architecture:** SwiftData for persistence, NavigationStack for list→chat flow, auto-save on message changes.

**Tech Stack:** SwiftData, SwiftUI, watchOS 10+

---

## Task 1: Add Codable to Message Model

**Files:**
- Modify: `WatchGPT Watch App/Models/Message.swift`

**Step 1: Add Codable conformance**

Add `Codable` to the struct declaration and make all properties codable-compatible:

```swift
struct Message: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let role: Role
    let content: String
    var isPlaying: Bool
    let timestamp: Date

    enum Role: String, Codable, Hashable {
        case user
        case assistant
        case system
    }

    // ... rest unchanged
}
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Models/Message.swift"
git commit -m "feat: add Codable conformance to Message"
```

---

## Task 2: Create Conversation Model

**Files:**
- Create: `WatchGPT Watch App/Models/Conversation.swift`

**Step 1: Create the model file**

```swift
import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var messagesData: Data
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.messagesData = (try? JSONEncoder().encode(messages)) ?? Data()
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var messages: [Message] {
        get {
            (try? JSONDecoder().decode([Message].self, from: messagesData)) ?? []
        }
        set {
            messagesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            updatedAt = Date()
        }
    }

    var title: String {
        let firstUserMessage = messages.first { $0.role == .user }?.content ?? "New Chat"
        if firstUserMessage.count > 30 {
            return String(firstUserMessage.prefix(30)) + "…"
        }
        return firstUserMessage
    }

    var previewTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
}
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Models/Conversation.swift"
git commit -m "feat: add Conversation model with SwiftData"
```

---

## Task 3: Update WatchGPTApp with SwiftData Container

**Files:**
- Modify: `WatchGPT Watch App/WatchGPTApp.swift`

**Step 1: Add SwiftData import and model container**

```swift
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
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/WatchGPTApp.swift"
git commit -m "feat: add SwiftData model container for Conversation"
```

---

## Task 4: Create ConversationListView

**Files:**
- Create: `WatchGPT Watch App/Views/ConversationListView.swift`

**Step 1: Create the conversation list view**

```swift
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
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ConversationListView.swift"
git commit -m "feat: add ConversationListView with list and delete"
```

---

## Task 5: Update ChatViewModel for Conversation Binding

**Files:**
- Modify: `WatchGPT Watch App/ViewModels/ChatViewModel.swift`

**Step 1: Replace the entire ChatViewModel**

```swift
import Foundation
import SwiftUI

/// Manages the chat conversation state and API interactions
@Observable
@MainActor
final class ChatViewModel {
    // MARK: - Published State

    var messages: [Message] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var inputText: String = ""

    // MARK: - Dependencies

    private let openAIService = OpenAIService.shared
    private let audioPlayer = AudioPlayer.shared

    // MARK: - Conversation Binding

    private var conversation: Conversation?
    private var onMessagesChanged: (([Message]) -> Void)?

    // MARK: - Initialization

    init() {}

    /// Binds the view model to a conversation for persistence
    func bind(to conversation: Conversation, onMessagesChanged: @escaping ([Message]) -> Void) {
        self.conversation = conversation
        self.onMessagesChanged = onMessagesChanged
        self.messages = conversation.messages

        // Restore conversation history in OpenAI service
        openAIService.clearConversation()
        for message in messages where message.role != .system {
            openAIService.restoreMessage(role: message.role.rawValue, content: message.content)
        }

        // Add welcome message if this is a new conversation
        if messages.isEmpty {
            addWelcomeMessage()
        }
    }

    // MARK: - Public Methods

    /// Sends a message to the assistant
    /// - Parameter content: The message content to send
    func sendMessage(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Add user message
        let userMessage = Message(role: .user, content: trimmed)
        withAnimation(Theme.messageAppear) {
            messages.append(userMessage)
            saveMessages()
        }

        // Clear input and show loading
        inputText = ""
        isLoading = true
        errorMessage = nil

        // Call OpenAI API
        Task { @MainActor in
            do {
                let response = try await openAIService.sendMessage(trimmed)

                let assistantMessage = Message(role: .assistant, content: response)
                withAnimation(Theme.messageAppear) {
                    messages.append(assistantMessage)
                    isLoading = false
                    saveMessages()
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription

                // Show error as assistant message
                let errorResponse = Message(
                    role: .assistant,
                    content: "Sorry, I couldn't respond. \(error.localizedDescription)"
                )
                withAnimation(Theme.messageAppear) {
                    messages.append(errorResponse)
                    saveMessages()
                }
            }
        }
    }

    /// Plays or stops audio for a specific message
    /// - Parameter message: The message to toggle audio for
    func toggleAudio(for message: Message) {
        guard message.isAssistant else { return }

        // If this message is already playing, stop it
        if audioPlayer.isPlaying(messageID: message.id) {
            audioPlayer.stop()
            updatePlayingState(for: message.id, isPlaying: false)
            return
        }

        // Stop any currently playing audio
        audioPlayer.stop()
        for i in messages.indices {
            messages[i].isPlaying = false
        }

        // Start playing this message
        updatePlayingState(for: message.id, isPlaying: true)

        Task { @MainActor in
            do {
                let audioData = try await openAIService.textToSpeech(message.content)
                try audioPlayer.play(data: audioData, for: message.id)

                // Monitor playback completion
                monitorPlaybackCompletion(for: message.id)
            } catch {
                updatePlayingState(for: message.id, isPlaying: false)
                errorMessage = "Audio playback failed: \(error.localizedDescription)"
            }
        }
    }

    /// Stops any currently playing audio
    func stopAudio() {
        audioPlayer.stop()
        for i in messages.indices {
            messages[i].isPlaying = false
        }
    }

    /// Clears the conversation and starts fresh
    func clearConversation() {
        stopAudio()
        openAIService.clearConversation()

        withAnimation {
            messages.removeAll()
            errorMessage = nil
            saveMessages()
        }
        addWelcomeMessage()
    }

    // MARK: - Private Methods

    private func addWelcomeMessage() {
        let welcome = Message(
            role: .assistant,
            content: "Hello! How can I help you today?"
        )
        withAnimation(Theme.messageAppear) {
            messages.append(welcome)
            saveMessages()
        }
    }

    private func saveMessages() {
        onMessagesChanged?(messages)
    }

    private func updatePlayingState(for messageID: UUID, isPlaying: Bool) {
        if let index = messages.firstIndex(where: { $0.id == messageID }) {
            messages[index].isPlaying = isPlaying
        }
    }

    private func monitorPlaybackCompletion(for messageID: UUID) {
        // Poll for playback completion
        Task { @MainActor in
            while audioPlayer.isPlaying(messageID: messageID) {
                try? await Task.sleep(for: .milliseconds(100))
            }
            updatePlayingState(for: messageID, isPlaying: false)
        }
    }
}
```

**Step 2: Add restoreMessage to OpenAIService**

In `Shared/OpenAIService.swift`, add this method after `clearConversation()`:

```swift
/// Restores a message to conversation history (for loading saved conversations)
func restoreMessage(role: String, content: String) {
    let message = ChatMessage(role: role, content: content)
    conversationHistory.append(message)
}
```

**Step 3: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**

```bash
git add "WatchGPT Watch App/ViewModels/ChatViewModel.swift" "Shared/OpenAIService.swift"
git commit -m "feat: update ChatViewModel for conversation persistence"
```

---

## Task 6: Update ChatView to Accept Conversation

**Files:**
- Modify: `WatchGPT Watch App/Views/ChatView.swift`

**Step 1: Update ChatView to accept conversation parameter**

Replace the state property and add binding:

```swift
import SwiftUI

/// Main chat interface with scrollable message list and floating compose button
struct ChatView: View {
    @Bindable var conversation: Conversation
    @State private var viewModel = ChatViewModel()
    @State private var showCompose: Bool = false
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Theme.background
                .ignoresSafeArea()

            // Message list
            messageList

            // Floating compose button
            composeButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.bind(to: conversation) { messages in
                conversation.messages = messages
            }
        }
        .sheet(isPresented: $showCompose) {
            ComposeView(
                text: $viewModel.inputText,
                onSend: { message in
                    viewModel.sendMessage(message)
                    scrollToBottom()
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // ... rest of the file stays the same (messageList, composeButton, scrollToBottom, etc.)
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ChatView.swift"
git commit -m "feat: update ChatView to accept Conversation binding"
```

---

## Task 7: Update ContentView to Show ConversationListView

**Files:**
- Modify: `WatchGPT Watch App/ContentView.swift`

**Step 1: Replace ContentView**

```swift
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
```

**Step 2: Build to verify**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/ContentView.swift"
git commit -m "feat: update ContentView to show ConversationListView"
```

---

## Task 8: Add Conversation.swift to Xcode Project

**Files:**
- Modify: `WatchGPT.xcodeproj/project.pbxproj`

**Step 1: Add file reference**

The new `Conversation.swift` file needs to be added to the Xcode project. Open Xcode and drag `WatchGPT Watch App/Models/Conversation.swift` into the Models group, or use the following command to verify the project builds:

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -3`

If it fails due to missing file, open Xcode and add the file to the project manually.

**Step 2: Commit if changes needed**

```bash
git add WatchGPT.xcodeproj/project.pbxproj
git commit -m "chore: add Conversation.swift to Xcode project"
```

---

## Task 9: Final Integration Test

**Step 1: Clean build**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' clean build 2>&1 | tail -5`

Expected: `** BUILD SUCCEEDED **`

**Step 2: Verify all files committed**

Run: `git status`

Expected: Nothing to commit, working tree clean

**Step 3: Push feature branch**

```bash
git push -u origin feature/chat-history
```

---

## Summary

After completing all tasks, the app will have:
- Persistent conversation storage via SwiftData
- Home screen listing all conversations (newest first)
- Auto-generated titles from first user message
- Swipe-to-delete functionality
- Conversation context preserved when returning to a chat
- All existing functionality (TTS, typing indicator, etc.) preserved
