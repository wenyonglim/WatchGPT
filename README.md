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

## Assistant Modes

Choose your assistant mode when creating a new chat:
- **SBR Tutor** - ACCA Strategic Business Reporting exam prep
- **General** - Helpful general assistant

## Settings

Tap the gear icon to access settings:
- **Model selector** - Choose GPT-5.2 (smarter) or GPT-5-mini (cheaper)

## Requirements

- watchOS 10.0+
- Xcode 15+
- OpenAI API key
