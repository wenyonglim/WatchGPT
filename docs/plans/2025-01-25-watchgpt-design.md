# WatchGPT Design Document

## Overview

An Apple Watch app for text-based ChatGPT conversations with audio playback.

## Requirements

- **Input**: Apple Watch keyboard (dictation, scribble, QWERTY)
- **Output**: Text responses displayed on screen + audio playback via OpenAI TTS
- **Conversation**: Session-based (context within session, cleared on app close)
- **Model**: GPT-5.2 (latest flagship)
- **API Key**: Configured via iPhone companion app, synced via WatchConnectivity, stored in Keychain

## Architecture

### Two-App Structure

1. **WatchGPT (Watch App)** - Main chat interface
   - SwiftUI standalone Watch app
   - Text input via system keyboard
   - Chat view with message bubbles
   - Audio playback of responses via OpenAI TTS API
   - Session-based conversation memory

2. **WatchGPT Companion (iPhone App)** - Setup only
   - Single-purpose: API key configuration
   - Secure text field for entering OpenAI API key
   - Syncs to Watch via WatchConnectivity
   - Key stored in Keychain on both devices

### Data Flow

```
User types → Watch App → OpenAI Chat API (GPT-5.2)
                              ↓
                         Text response
                              ↓
                    ┌────────┴────────┐
                    ↓                 ↓
              Display text    OpenAI TTS API
                                    ↓
                              Audio playback
```

## UI Design

### Color Palette (OLED-Optimized)

| Element | Color | Hex |
|---------|-------|-----|
| Background | Pure black | `#000000` |
| User message bubble | Dark gray | `#1C1C1E` |
| Assistant message | No bubble, white text | - |
| Accent (send, active) | Green | `#30D158` |
| Primary text | White | `#FFFFFF` |
| Secondary text | Gray | `#8E8E93` |

### Screens

#### 1. Chat View (Main)
- Full-screen scrollable message list
- User messages: right-aligned, dark gray bubble
- Assistant messages: left-aligned, no bubble, white text
- Tap-to-speak button on each assistant message (small speaker icon)
- Floating compose button at bottom
- No timestamps, no avatars - minimal design

#### 2. Compose View (Modal)
- Opens system keyboard
- Single text field, auto-focused
- Send button (green accent)
- Cancel button to dismiss

#### 3. Loading State
- Subtle pulsing dot indicator
- Appears as "typing" placeholder from assistant

### Typography
- Font: SF Pro Rounded
- Body: 15pt
- No bold except for errors

## Technical Stack

- **Watch App**: SwiftUI, WatchKit
- **iPhone App**: SwiftUI
- **Networking**: URLSession for OpenAI API calls
- **Sync**: WatchConnectivity framework
- **Storage**: Keychain for API key
- **Audio**: AVFoundation for TTS playback

## API Integration

### OpenAI Chat Completions
- Endpoint: `https://api.openai.com/v1/chat/completions`
- Model: `gpt-5.2`
- Maintain conversation history array in memory for session context

### OpenAI TTS
- Endpoint: `https://api.openai.com/v1/audio/speech`
- Model: `tts-1` (or `tts-1-hd` for higher quality)
- Voice: To be determined (alloy, echo, fable, onyx, nova, shimmer)
- Format: AAC for smaller file size on Watch

## Next Steps

1. Set up Xcode project with Watch + iPhone targets
2. Implement WatchConnectivity for API key sync
3. Build iPhone settings UI
4. Build Watch chat UI (use frontend-design plugin)
5. Integrate OpenAI Chat API
6. Integrate OpenAI TTS API
7. Test end-to-end flow
