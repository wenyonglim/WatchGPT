# Assistant Mode Selection Design

## Overview

Add per-conversation assistant mode selection. Users choose between SBR Tutor and General assistant when creating a new chat.

## Data Model

Add `mode` property to `Conversation`:

```swift
var mode: String  // "sbr" or "general"
```

Default: `"sbr"` (for current SBR study focus)

## Modes

| Mode | Icon | System Prompt |
|------|------|---------------|
| `sbr` | 📚 | SBR Tutor - ACCA exam prep, IFRS, Group Accounting |
| `general` | 💬 | General helpful assistant |

Both prompts include "Keep responses concise for Apple Watch."

## UI Flow

1. Tap "New Chat" on ConversationListView
2. Sheet appears with mode options
3. Tap mode → creates conversation with that mode → navigates to ChatView
4. Conversation list shows mode icon on each row

## Files to Change

1. `Conversation.swift` - Add `mode` property
2. `OpenAIService.swift` - Add `AssistantMode` enum, method to get prompt by mode
3. `ConversationListView.swift` - Show mode picker sheet, display mode icon on rows
4. `ChatViewModel.swift` - Pass mode to OpenAIService when sending messages
