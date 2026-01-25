# Chat History Design Document

## Overview

Add persistent chat history to WatchGPT, allowing users to save conversations, return to previous chats, and delete old ones.

## Data Model

### Conversation

```swift
struct Conversation: Identifiable, Codable {
    let id: UUID
    var messages: [Message]
    let createdAt: Date
    var updatedAt: Date

    var title: String {
        messages.first { $0.role == .user }?.content.prefix(30) ?? "New Chat"
    }
}
```

### Message Changes

Add `Codable` conformance to existing `Message` struct for persistence.

## Storage

- **Framework**: SwiftData (watchOS 10+)
- **Auto-save**: Conversations persist automatically when modified
- **Location**: App's default SwiftData container

## UI Changes

### New: ConversationListView (Home Screen)

- Full-width rows: title + relative timestamp ("2h ago")
- "New Chat" button at top (green accent)
- Swipe-to-delete on each row
- Empty state with prominent New Chat button
- Sorted by updatedAt, newest first

### Modified: ChatView

- Receives `Conversation` binding instead of creating own state
- Saves automatically as messages added
- Back navigation to list

### Navigation Flow

```
App Launch → ConversationListView → ChatView (with conversation)
```

## Files to Create/Modify

| File | Action |
|------|--------|
| `Models/Conversation.swift` | Create |
| `Models/Message.swift` | Modify (add Codable) |
| `Services/ConversationStore.swift` | Create |
| `Views/ConversationListView.swift` | Create |
| `Views/ChatView.swift` | Modify |
| `ContentView.swift` | Modify |
| `WatchGPTApp.swift` | Modify (add SwiftData container)

## Design Decisions

- **Auto-title**: First user message truncated to 30 chars
- **No confirmation on delete**: watchOS convention, swipe-to-delete is reversible
- **Newest first**: Most relevant chats at top
