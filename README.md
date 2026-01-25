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

## Requirements

- watchOS 10.0+
- Xcode 15+
- OpenAI API key
