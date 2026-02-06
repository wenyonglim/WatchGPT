import Foundation
import SwiftData

@Model
final class Conversation {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    private static let previewFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

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
        self.messagesData = Self.encode(messages)
        self.mode = mode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var messages: [Message] {
        get {
            Self.decode(messagesData)
        }
        set {
            messagesData = Self.encode(newValue)
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
        Self.previewFormatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    private static func encode(_ messages: [Message]) -> Data {
        (try? encoder.encode(messages)) ?? Data()
    }

    private static func decode(_ data: Data) -> [Message] {
        (try? decoder.decode([Message].self, from: data)) ?? []
    }
}
