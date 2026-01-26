import SwiftUI

/// Displays a single message with appropriate styling based on role
struct MessageBubble: View {
    let message: Message
    let onPlayAudio: () -> Void

    @State private var isPressed: Bool = false
    @State private var appeared: Bool = false
    @AppStorage("nightMode") private var nightMode = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.isUser {
                Spacer(minLength: 24)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                messageContent
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(Theme.messageAppear) {
                appeared = true
            }
        }
    }

    // MARK: - Message Content

    @ViewBuilder
    private var messageContent: some View {
        if message.isUser {
            userMessage
        } else {
            assistantMessage
        }
    }

    /// User message: right-aligned with dark gray bubble (or black in night mode)
    private var userMessage: some View {
        Text(message.content)
            .font(Theme.body)
            .foregroundStyle(Theme.primaryText)
            .padding(.horizontal, Theme.bubblePadding)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.bubbleCornerRadius, style: .continuous)
                    .fill(Theme.userBubbleColor(nightMode: nightMode))
                    .stroke(nightMode ? Theme.nightAccent.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .multilineTextAlignment(.trailing)
    }

    /// Assistant message: left-aligned, no bubble, with speaker button
    private var assistantMessage: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(message.content)
                .font(Theme.body)
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.leading)

            speakerButton
        }
        .padding(.horizontal, Theme.bubblePadding)
    }

    /// Speaker icon button for audio playback
    private var speakerButton: some View {
        Button {
            onPlayAudio()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: message.isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(message.isPlaying ? Theme.speakerIconActiveColor(nightMode: nightMode) : Theme.speakerIcon)
                    .symbolEffect(.variableColor.iterative, isActive: message.isPlaying)

                if message.isPlaying {
                    Text("Playing")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.speakerIconActiveColor(nightMode: nightMode))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Theme.userBubble.opacity(0.6))
                    .opacity(isPressed ? 1 : 0)
            )
            .scaleEffect(isPressed ? 0.92 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
        .sensoryFeedback(.impact(flexibility: .soft), trigger: message.isPlaying)
    }
}

// MARK: - Preview

#Preview("User Message") {
    ZStack {
        Theme.background.ignoresSafeArea()
        VStack {
            MessageBubble(
                message: Message(role: .user, content: "Hello, how are you?"),
                onPlayAudio: {}
            )
            Spacer()
        }
        .padding()
    }
}

#Preview("Assistant Message") {
    ZStack {
        Theme.background.ignoresSafeArea()
        VStack {
            MessageBubble(
                message: Message(role: .assistant, content: "I'm doing great! How can I help you today?"),
                onPlayAudio: {}
            )
            Spacer()
        }
        .padding()
    }
}

#Preview("Playing Audio") {
    ZStack {
        Theme.background.ignoresSafeArea()
        VStack {
            MessageBubble(
                message: Message(role: .assistant, content: "This message is being read aloud.", isPlaying: true),
                onPlayAudio: {}
            )
            Spacer()
        }
        .padding()
    }
}
