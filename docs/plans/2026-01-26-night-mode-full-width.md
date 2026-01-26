# Night Mode & Full-Width Messages Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Night Mode toggle (dark red accent) and make assistant messages full-width.

**Architecture:** Extend Theme.swift with a night accent color and a function that returns the appropriate accent based on a boolean. Add toggle to SettingsView. Remove right-side spacer from assistant messages in MessageBubble.

**Tech Stack:** SwiftUI, @AppStorage for persistence

---

### Task 1: Add Night Accent Color to Theme

**Files:**
- Modify: `Shared/Theme.swift:14-15`

**Step 1: Add nightAccent color constant**

Add after line 15 (after `accent` definition):

```swift
/// Night mode accent - dark red for reduced blue light
static let nightAccent = Color(hex: 0xD94535)
```

**Step 2: Add accent function that takes nightMode parameter**

Add after `nightAccent` (around line 18):

```swift
/// Returns appropriate accent color based on night mode
static func accentColor(nightMode: Bool) -> Color {
    nightMode ? nightAccent : accent
}
```

**Step 3: Add semantic color functions for speaker icons**

Replace lines 28-30:

```swift
static let sendButton = accent
static let speakerIcon = secondaryText
static let speakerIconActive = accent
```

With:

```swift
static func sendButtonColor(nightMode: Bool) -> Color {
    accentColor(nightMode: nightMode)
}
static let speakerIcon = secondaryText
static func speakerIconActiveColor(nightMode: Bool) -> Color {
    accentColor(nightMode: nightMode)
}
```

**Step 4: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Shared/Theme.swift
git commit -m "feat: add night mode colors to Theme"
```

---

### Task 2: Add Night Mode Toggle to Settings

**Files:**
- Modify: `WatchGPT Watch App/Views/SettingsView.swift:33-61`

**Step 1: Add nightMode AppStorage property**

Add after line 35 (after `selectedModel` property):

```swift
@AppStorage("nightMode") private var nightMode = false
```

**Step 2: Add Display section with toggle**

Add inside `List` before the AI Model section (after line 38, before `Section {`):

```swift
Section {
    Toggle(isOn: $nightMode) {
        HStack(spacing: 8) {
            Image(systemName: "moon.fill")
                .foregroundStyle(nightMode ? Theme.nightAccent : Theme.secondaryText)
            Text("Night Mode")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.primaryText)
        }
    }
    .tint(Theme.nightAccent)
} header: {
    Text("Display")
        .font(.system(.caption2, design: .rounded))
        .foregroundStyle(Theme.secondaryText)
}
```

**Step 3: Update checkmark to use dynamic accent**

Replace line 91:

```swift
.foregroundStyle(Theme.accent)
```

With:

```swift
.foregroundStyle(Theme.accentColor(nightMode: nightMode))
```

**Step 4: Pass nightMode to ModelRow**

Update ModelRow struct to accept nightMode parameter. Replace the struct (lines 66-97):

```swift
private struct ModelRow: View {
    let model: AIModel
    let isSelected: Bool
    let nightMode: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(model.displayName)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Theme.primaryText)

                    Text(model.costIndicator)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                }

                Text(model.description)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.accentColor(nightMode: nightMode))
            }
        }
        .padding(.vertical, 4)
    }
}
```

**Step 5: Update ModelRow instantiation**

Replace line 41-44:

```swift
ModelRow(
    model: model,
    isSelected: selectedModel == model.rawValue
)
```

With:

```swift
ModelRow(
    model: model,
    isSelected: selectedModel == model.rawValue,
    nightMode: nightMode
)
```

**Step 6: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add WatchGPT\ Watch\ App/Views/SettingsView.swift
git commit -m "feat: add Night Mode toggle to settings"
```

---

### Task 3: Make Assistant Messages Full-Width

**Files:**
- Modify: `WatchGPT Watch App/Views/MessageBubble.swift:21-23`

**Step 1: Remove assistant message right spacer**

Delete lines 21-23:

```swift
if message.isAssistant {
    Spacer(minLength: 24)
}
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add WatchGPT\ Watch\ App/Views/MessageBubble.swift
git commit -m "feat: make assistant messages full-width"
```

---

### Task 4: Update MessageBubble to Use Dynamic Accent

**Files:**
- Modify: `WatchGPT Watch App/Views/MessageBubble.swift`

**Step 1: Add nightMode AppStorage property**

Add after line 9 (after `appeared` state):

```swift
@AppStorage("nightMode") private var nightMode = false
```

**Step 2: Update speaker icon active color**

Replace line 80:

```swift
.foregroundStyle(message.isPlaying ? Theme.speakerIconActive : Theme.speakerIcon)
```

With:

```swift
.foregroundStyle(message.isPlaying ? Theme.speakerIconActiveColor(nightMode: nightMode) : Theme.speakerIcon)
```

**Step 3: Update "Playing" text color**

Replace line 86:

```swift
.foregroundStyle(Theme.speakerIconActive)
```

With:

```swift
.foregroundStyle(Theme.speakerIconActiveColor(nightMode: nightMode))
```

**Step 4: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add WatchGPT\ Watch\ App/Views/MessageBubble.swift
git commit -m "feat: use dynamic accent in MessageBubble"
```

---

### Task 5: Update ComposeView to Use Dynamic Accent

**Files:**
- Modify: `WatchGPT Watch App/Views/ComposeView.swift`

**Step 1: Read current file to find accent usages**

Check file for `Theme.accent` or `Theme.sendButton` usages.

**Step 2: Add nightMode AppStorage if needed**

Add property:

```swift
@AppStorage("nightMode") private var nightMode = false
```

**Step 3: Replace static accent references with dynamic**

Replace any `Theme.accent` with `Theme.accentColor(nightMode: nightMode)`
Replace any `Theme.sendButton` with `Theme.sendButtonColor(nightMode: nightMode)`

**Step 4: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add WatchGPT\ Watch\ App/Views/ComposeView.swift
git commit -m "feat: use dynamic accent in ComposeView"
```

---

### Task 6: Update Remaining Views for Dynamic Accent

**Files:**
- Check and modify: `WatchGPT Watch App/Views/ChatView.swift`
- Check and modify: `WatchGPT Watch App/Views/TypingIndicator.swift`
- Check and modify: `WatchGPT Watch App/Views/ConversationListView.swift`

**Step 1: Search for Theme.accent usages**

Find all files using `Theme.accent` and update to use `Theme.accentColor(nightMode:)`.

**Step 2: Add nightMode AppStorage to each view that needs it**

```swift
@AppStorage("nightMode") private var nightMode = false
```

**Step 3: Replace static accent references**

Replace `Theme.accent` with `Theme.accentColor(nightMode: nightMode)` in each file.

**Step 4: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -20`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add WatchGPT\ Watch\ App/Views/
git commit -m "feat: use dynamic accent in all views"
```

---

### Task 7: Final Verification

**Step 1: Clean build**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' clean build 2>&1 | tail -30`
Expected: BUILD SUCCEEDED

**Step 2: Manual test checklist**

- [ ] Open app, verify default green accent
- [ ] Go to Settings, toggle Night Mode ON
- [ ] Verify all accents change to dark red
- [ ] Send a message, verify send button is red
- [ ] Receive response, verify it's full-width
- [ ] Play audio, verify speaker icon is red
- [ ] Toggle Night Mode OFF, verify green returns
- [ ] Kill and reopen app, verify setting persisted
