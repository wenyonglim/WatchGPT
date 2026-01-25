# Model Selector Design Document

## Overview

Add a global setting to switch between GPT-5.2 (powerful) and GPT-5-mini (cost-effective) models.

## Models

| Model | Input Cost | Output Cost | Reasoning | Use Case |
|-------|------------|-------------|-----------|----------|
| gpt-5.2 | $1.75/1M | $14.00/1M | Excellent | Complex exam scenarios |
| gpt-5-mini | $0.25/1M | $2.00/1M | Good | Daily study |

## Storage

- **Location**: UserDefaults
- **Key**: `selectedModel`
- **Values**: `"gpt-5.2"` or `"gpt-5-mini"`
- **Default**: `"gpt-5.2"`

## UI

Settings gear icon on ConversationListView → Opens SettingsView with model picker.

## Files to Change

1. `Shared/OpenAIService.swift` - Read model from UserDefaults
2. `WatchGPT Watch App/Views/SettingsView.swift` - New settings view
3. `WatchGPT Watch App/Views/ConversationListView.swift` - Add gear button
4. `WatchGPT.xcodeproj/project.pbxproj` - Add new file
