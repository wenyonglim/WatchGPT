import SwiftUI

/// Modal view for composing and sending messages
struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    let onSend: (String) -> Void

    @State private var appearAnimation: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @AppStorage("nightMode") private var nightMode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                textField
                sendButton
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            // Delay focus to let animation complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Components

    /// Text field for message input
    private var textField: some View {
        TextField("Message", text: $text, axis: .vertical)
            .font(Theme.body)
            .foregroundStyle(Theme.primaryText)
            .focused($isTextFieldFocused)
            .lineLimit(1...4)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.userBubble)
            )
            .tint(Theme.accentColor(nightMode: nightMode))
    }

    /// Send button with green accent
    private var sendButton: some View {
        Button {
            sendMessage()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                Text("Send")
                    .font(Theme.bodyMedium)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(canSend ? Theme.sendButtonColor(nightMode: nightMode) : Theme.sendButtonColor(nightMode: nightMode).opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: canSend)
    }

    /// Cancel button to dismiss
    private var cancelButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                appearAnimation = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        } label: {
            Text("Cancel")
                .font(Theme.body)
                .foregroundStyle(Theme.secondaryText)
        }
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendMessage() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        onSend(trimmedText)

        withAnimation(.easeOut(duration: 0.2)) {
            appearAnimation = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    ComposeView(
        text: .constant(""),
        onSend: { _ in }
    )
}

#Preview("With Text") {
    ComposeView(
        text: .constant("Hello, I have a question about..."),
        onSend: { _ in }
    )
}
