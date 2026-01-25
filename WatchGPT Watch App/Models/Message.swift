import Foundation

/// Represents a single message in the chat conversation
struct Message: Identifiable, Equatable, Hashable {
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

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        isPlaying: Bool = false,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.isPlaying = isPlaying
        self.timestamp = timestamp
    }

    var isUser: Bool {
        role == .user
    }

    var isAssistant: Bool {
        role == .assistant
    }
}

// MARK: - OpenAI API Format

extension Message {
    /// Converts to OpenAI chat completion message format
    var apiFormat: [String: String] {
        ["role": role.rawValue, "content": content]
    }
}
