import XCTest

final class ConversationPersistenceTests: XCTestCase {
    func testMessagesRoundTrip() {
        let messages = [
            Message(role: .user, content: "Hello"),
            Message(role: .assistant, content: "Hi there"),
        ]
        let conversation = Conversation(messages: messages)

        XCTAssertEqual(conversation.messages.count, 2)
        XCTAssertEqual(conversation.messages[0].content, "Hello")
        XCTAssertEqual(conversation.messages[1].role, .assistant)
    }

    func testTitleUsesFirstUserMessage() {
        let messages = [
            Message(role: .assistant, content: "Welcome"),
            Message(role: .user, content: "First user message in thread"),
        ]
        let conversation = Conversation(messages: messages)
        XCTAssertEqual(conversation.title, "First user message in thread")
    }
}
