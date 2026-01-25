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
