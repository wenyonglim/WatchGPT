import SwiftUI

/// A subtle pulsing indicator that shows the assistant is typing
struct TypingIndicator: View {
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Theme.typingIndicator)
                    .frame(width: 6, height: 6)
                    .scaleEffect(dotScale(for: index))
                    .opacity(dotOpacity(for: index))
            }
        }
        .padding(.horizontal, Theme.bubblePadding)
        .padding(.vertical, 10)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                animationPhase = 1
            }
        }
    }

    // MARK: - Animation Calculations

    /// Calculates scale for each dot based on animation phase
    private func dotScale(for index: Int) -> CGFloat {
        let offset = Double(index) * 0.2
        let phase = (animationPhase + offset).truncatingRemainder(dividingBy: 1.0)
        return 0.6 + 0.4 * sin(phase * .pi * 2)
    }

    /// Calculates opacity for each dot based on animation phase
    private func dotOpacity(for index: Int) -> CGFloat {
        let offset = Double(index) * 0.2
        let phase = (animationPhase + offset).truncatingRemainder(dividingBy: 1.0)
        return 0.4 + 0.6 * sin(phase * .pi * 2)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        VStack {
            TypingIndicator()
            Spacer()
        }
    }
}
