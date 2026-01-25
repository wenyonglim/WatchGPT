# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WatchGPT is a standalone Apple Watch app for ChatGPT conversations with text input and TTS audio playback.

## Build & Run

This is an Xcode project (`WatchGPT.xcodeproj`):
- Open in Xcode, select "WatchGPT Watch App" target, run on simulator/device
- **Deployment target**: watchOS 10.0+
- **Swift version**: 5.9+ (uses `@Observable` macro)

**Setup**: Copy your OpenAI API key into `Shared/Secrets.swift` before building.

## Architecture

### Directory Structure

```
WatchGPT Watch App/       # Watch app
├── Views/                # SwiftUI views (ChatView, ComposeView, MessageBubble, TypingIndicator)
├── ViewModels/           # ChatViewModel (chat state & logic)
├── Models/               # Message data model
└── Services/             # AudioPlayer (TTS playback)

Shared/                   # Shared code
├── OpenAIService.swift   # OpenAI Chat + TTS API client
├── Secrets.swift         # API key (gitignored)
└── Theme.swift           # OLED-optimized design system
```

### Key Patterns

- **MVVM with Observable**: `@Observable` macro for reactive state (iOS 17+)
- **Singletons**: Services use `static let shared` (OpenAIService, AudioPlayer)
- **Data flow**: User input → ChatViewModel → OpenAIService → API → Update messages → Optional TTS via AudioPlayer

### OpenAI Integration

- **Chat**: `gpt-4o` model via `/v1/chat/completions`
- **TTS**: `tts-1` model with "alloy" voice, AAC format via `/v1/audio/speech`
- **System prompt**: Instructs assistant to keep responses concise for Watch screen
- **Conversation history**: Maintained in-memory for session context

## Design System

OLED-optimized colors defined in `Theme.swift`:
- Background: Pure black (#000000)
- User bubbles: Dark gray (#1C1C1E)
- Accent: Green (#30D158)
- Animations: Spring (response: 0.35, damping: 0.7)

## Scripts

- `Scripts/generate_watch_icons.swift` - Generates app icon sizes, outputs to Watch App assets
