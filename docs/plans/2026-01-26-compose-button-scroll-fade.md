# Compose Button Scroll Fade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the compose button fade out proportionally when scrolling up, and fade back in when near the bottom.

**Architecture:** Use `.onScrollGeometryChange` (watchOS 11+) to track scroll position. Calculate button opacity based on distance from the bottom of the content. Map scroll offset to opacity with smooth interpolation.

**Tech Stack:** SwiftUI, watchOS 11+

---

### Task 1: Add Scroll Position State

**Files:**
- Modify: `WatchGPT Watch App/Views/ChatView.swift`

**Step 1: Add state variable for button opacity**

Add after line 9 (after `nightMode` property):

```swift
@State private var composeButtonOpacity: Double = 1.0
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ChatView.swift"
git commit -m "feat: add compose button opacity state"
```

---

### Task 2: Track Scroll Position with onScrollGeometryChange

**Files:**
- Modify: `WatchGPT Watch App/Views/ChatView.swift`

**Step 1: Add scroll geometry tracking to ScrollView**

Replace the ScrollView section (lines 46-72) - add `.onScrollGeometryChange` after `.scrollIndicators(.hidden)`:

```swift
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Theme.messagePadding) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            onPlayAudio: {
                                viewModel.toggleAudio(for: message)
                            }
                        )
                        .id(message.id)
                    }

                    // Typing indicator when loading
                    if viewModel.isLoading {
                        TypingIndicator()
                            .id("typing")
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Bottom spacer for compose button
                    Color.clear
                        .frame(height: 60)
                        .id("bottom")
                }
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, Theme.screenPadding)
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: Double.self) { geometry in
                // Calculate distance from bottom
                let contentHeight = geometry.contentSize.height
                let viewHeight = geometry.visibleRect.height
                let offsetY = geometry.contentOffset.y
                let distanceFromBottom = contentHeight - viewHeight - offsetY
                return distanceFromBottom
            } action: { oldValue, newValue in
                // Map distance to opacity: fully visible at bottom (0-30), fade out over 30-100 range
                let opacity = min(1.0, max(0.0, newValue / 70.0))
                withAnimation(.easeOut(duration: 0.15)) {
                    composeButtonOpacity = opacity
                }
            }
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ChatView.swift"
git commit -m "feat: track scroll position for compose button fade"
```

---

### Task 3: Apply Opacity to Compose Button

**Files:**
- Modify: `WatchGPT Watch App/Views/ChatView.swift`

**Step 1: Update compose button opacity**

Find the composeButton view and update the opacity modifier. Replace:

```swift
.opacity(viewModel.isLoading ? 0.6 : 1)
```

With:

```swift
.opacity(viewModel.isLoading ? 0.6 : composeButtonOpacity)
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ChatView.swift"
git commit -m "feat: apply scroll-based opacity to compose button"
```

---

### Task 4: Handle Edge Cases

**Files:**
- Modify: `WatchGPT Watch App/Views/ChatView.swift`

**Step 1: Ensure button shows on initial load and after sending message**

Update the `scrollToBottom()` function to also reset opacity:

```swift
private func scrollToBottom() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
        scrollProxy?.scrollTo("bottom", anchor: .bottom)
    }
    // Ensure button is visible when scrolled to bottom
    withAnimation(.easeOut(duration: 0.15)) {
        composeButtonOpacity = 1.0
    }
}
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "WatchGPT Watch App/Views/ChatView.swift"
git commit -m "feat: ensure compose button visible after scroll to bottom"
```

---

### Task 5: Final Verification

**Step 1: Clean build**

Run: `xcodebuild -project WatchGPT.xcodeproj -scheme "WatchGPT Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' clean build 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

**Step 2: Manual test checklist**

- [ ] Open a chat with messages
- [ ] Scroll up - button should fade out proportionally
- [ ] Scroll to bottom - button should be fully visible
- [ ] Send a message - button should remain visible
- [ ] Receive response - button should remain visible
- [ ] With few/no messages, button should be visible
