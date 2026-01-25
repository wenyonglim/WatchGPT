# WatchGPT

A standalone Apple Watch app for ChatGPT conversations with text input and TTS audio playback.

## Setup

1. Clone the repo and open `WatchGPT.xcodeproj` in Xcode
2. Create `Shared/Secrets.swift` with your OpenAI API key:
   ```swift
   enum Secrets {
       static let openAIAPIKey = "sk-your-api-key-here"
   }
   ```
3. Build and run the "WatchGPT Watch App" target

## Customizing the Assistant

To change the assistant's personality or focus, edit the system prompt in `Shared/OpenAIService.swift`:

```swift
static let systemPrompt = "Your custom instructions here..."
```

**Current mode:** SBR Tutor (ACCA Strategic Business Reporting exam prep)

## Future Ideas

- [ ] Mode switching UI (SBR Tutor ↔ Personal Advisor)
- [ ] Model selector to switch between GPT-4o / GPT-4o-mini for cost savings

## Requirements

- watchOS 10.0+
- Xcode 15+
- OpenAI API key
