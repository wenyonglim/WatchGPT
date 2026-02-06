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
    @AppStorage("selectedModel") private var selectedModel = AIModel.gpt5_2.rawValue
    @AppStorage("nightMode") private var nightMode = false
    @State private var showAPIKeyView = false

    var body: some View {
        List {
            // Custom title header
            Section {
                Text("Settings")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                    .listRowBackground(Color.clear)
            }

            Section {
                Toggle(isOn: $nightMode) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(nightMode ? Theme.nightAccent : Theme.secondaryTextColor(nightMode: nightMode))
                        Text("Night Mode")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))
                    }
                }
                .tint(Theme.nightAccent)
            } header: {
                Text("Display")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }

            Section {
                ForEach(AIModel.allCases) { model in
                    ModelRow(
                        model: model,
                        isSelected: selectedModel == model.rawValue,
                        nightMode: nightMode
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedModel = model.rawValue
                    }
                }
            } header: {
                Text("AI Model")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }

            Section {
                Button {
                    showAPIKeyView = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("API Key")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))

                            Text(KeychainService.hasAPIKey() ? "Saved in Keychain" : "Not set")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("Security")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
            }
        }
        .listStyle(.plain)
        .background(Theme.background)
        .scrollContentBackground(.hidden)
        .navigationTitle("")
        .navigationDestination(isPresented: $showAPIKeyView) {
            APIKeyView(onSaved: nil)
        }
    }
}

// MARK: - Model Row

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
                        .foregroundStyle(Theme.primaryTextColor(nightMode: nightMode))

                    Text(model.costIndicator)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Theme.accentColor(nightMode: nightMode))
                }

                Text(model.description)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.secondaryTextColor(nightMode: nightMode))
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

#Preview {
    NavigationStack {
        SettingsView()
    }
}
