import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var messagesData: Data
    var mode: String = "sbr"
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        messages: [Message] = [],
        mode: String = "sbr",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.messagesData = (try? JSONEncoder().encode(messages)) ?? Data()
        self.mode = mode
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
