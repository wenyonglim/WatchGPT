import SwiftUI

/// Main chat interface with scrollable message list and floating compose button
struct ChatView: View {
    @Bindable var conversation: Conversation
    @State private var viewModel = ChatViewModel()
    @State private var showCompose: Bool = false
    @State private var scrollProxy: ScrollViewProxy?
    @AppStorage("nightMode") private var nightMode = false
    @State private var composeButtonOpacity: Double = 1.0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Theme.background
                .ignoresSafeArea()

            // Message list
            messageList

            // Floating compose button
            composeButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.bind(to: conversation) { messages in
                conversation.messages = messages
            }
        }
        .sheet(isPresented: $showCompose) {
            ComposeView(
                text: $viewModel.inputText,
                onSend: { message in
                    viewModel.sendMessage(message)
                    scrollToBottom()
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
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
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom()
            }
            .onChange(of: viewModel.isLoading) { _, isLoading in
                if isLoading {
                    scrollToBottom()
                }
            }
        }
    }

    // MARK: - Compose Button

    private var composeButton: some View {
        Button {
            showCompose = true
        } label: {
            ZStack {
                // Button background with subtle glow
                Circle()
                    .fill(Theme.accentColor(nightMode: nightMode))
                    .frame(width: 48, height: 48)
                    .shadow(color: Theme.accentColor(nightMode: nightMode).opacity(0.4), radius: 8, x: 0, y: 2)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(ComposeButtonStyle())
        .padding(.bottom, 8)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: showCompose)
    }

    // MARK: - Helpers

    private func scrollToBottom() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            scrollProxy?.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// MARK: - Compose Button Style

private struct ComposeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    let conversation = Conversation()
    return ChatView(conversation: conversation)
        .modelContainer(for: Conversation.self, inMemory: true)
}
