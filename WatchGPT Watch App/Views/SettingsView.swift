import SwiftUI

/// Available AI models with their display names and costs
enum AIModel: String, CaseIterable, Identifiable {
    case gpt5_2 = "gpt-5.2"
    case gpt5_mini = "gpt-5-mini"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gpt5_2: return "GPT-5.2"
        case .gpt5_mini: return "GPT-5 mini"
        }
    }

    var costIndicator: String {
        switch self {
        case .gpt5_2: return "$$$"
        case .gpt5_mini: return "$"
        }
    }

    var description: String {
        switch self {
        case .gpt5_2: return "Best reasoning"
        case .gpt5_mini: return "Cost-effective"
        }
    }
}

/// Settings view for configuring app preferences
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedModel") private var selectedModel = AIModel.gpt5_2.rawValue

    var body: some View {
        List {
            Section {
                ForEach(AIModel.allCases) { model in
                    ModelRow(
                        model: model,
                        isSelected: selectedModel == model.rawValue
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedModel = model.rawValue
                    }
                }
            } header: {
                Text("AI Model")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .listStyle(.plain)
        .background(Theme.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Model Row

private struct ModelRow: View {
    let model: AIModel
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(model.displayName)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Theme.primaryText)

                    Text(model.costIndicator)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }

                Text(model.description)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
