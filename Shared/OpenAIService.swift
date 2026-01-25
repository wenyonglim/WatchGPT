import Foundation

// MARK: - Error Types

/// Errors that can occur when interacting with the OpenAI API
enum OpenAIError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case apiError(String)
    case decodingError(Error)
    case invalidURL
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenAI API key in Secrets.swift."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let statusCode, let message):
            if let message = message {
                return "HTTP \(statusCode): \(message)"
            }
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL."
        case .emptyResponse:
            return "Empty response from API."
        }
    }
}

// MARK: - Chat Models

/// A message in the conversation
struct ChatMessage: Codable, Equatable, Identifiable {
    let id: UUID
    let role: String
    let content: String

    init(id: UUID = UUID(), role: String, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }

    enum CodingKeys: String, CodingKey {
        case role, content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.role = try container.decode(String.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }

    static func user(_ content: String) -> ChatMessage {
        ChatMessage(role: "user", content: content)
    }

    static func assistant(_ content: String) -> ChatMessage {
        ChatMessage(role: "assistant", content: content)
    }

    static func system(_ content: String) -> ChatMessage {
        ChatMessage(role: "system", content: content)
    }
}

// MARK: - Chat Completion API Models

/// Request body for chat completions endpoint
private struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
    let maxTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

/// Response from chat completions endpoint
private struct ChatCompletionResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?

    struct Choice: Decodable {
        let index: Int
        let message: ChatMessage
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }

    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - TTS API Models

/// Request body for text-to-speech endpoint
private struct TTSRequest: Encodable {
    let model: String
    let input: String
    let voice: String
    let responseFormat: String

    enum CodingKeys: String, CodingKey {
        case model, input, voice
        case responseFormat = "response_format"
    }
}

// MARK: - Error Response Model

/// Error response from OpenAI API
private struct APIErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }
}

// MARK: - OpenAI Service

/// Service for interacting with OpenAI APIs (Chat Completions and Text-to-Speech)
@Observable
final class OpenAIService {
    // MARK: - Singleton

    static let shared = OpenAIService()

    // MARK: - Constants

    private enum Constants {
        static let chatCompletionsURL = "https://api.openai.com/v1/chat/completions"
        static let ttsURL = "https://api.openai.com/v1/audio/speech"
        static let chatModel = "gpt-4o"
        static let ttsModel = "tts-1"
        static let ttsVoice = "alloy"
        static let ttsFormat = "aac"
        static let defaultTemperature = 0.7
        static let defaultMaxTokens = 1024
        static let systemPrompt = "You are a helpful assistant on Apple Watch. Keep responses concise and clear due to the small screen size."
    }

    // MARK: - Properties

    /// Conversation history for maintaining context
    private(set) var conversationHistory: [ChatMessage] = []

    /// API key from Secrets
    private let apiKey = Secrets.openAIAPIKey

    /// URL session for network requests
    private let session: URLSession

    /// JSON encoder configured for API requests
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    /// JSON decoder configured for API responses
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Initialization

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    /// Clears the conversation history
    func clearConversation() {
        conversationHistory.removeAll()
    }

    /// Restores a message to conversation history (for loading saved conversations)
    func restoreMessage(role: String, content: String) {
        let message = ChatMessage(role: role, content: content)
        conversationHistory.append(message)
    }

    /// Sends a message to the chat completions API and returns the response
    /// - Parameter content: The user's message content
    /// - Returns: The assistant's response text
    /// - Throws: OpenAIError if the request fails
    func sendMessage(_ content: String) async throws -> String {
        let apiKey = try getAPIKey()

        // Add user message to history
        let userMessage = ChatMessage.user(content)
        conversationHistory.append(userMessage)

        // Build messages array with system prompt
        var messages = [ChatMessage.system(Constants.systemPrompt)]
        messages.append(contentsOf: conversationHistory)

        // Create request body
        let requestBody = ChatCompletionRequest(
            model: Constants.chatModel,
            messages: messages,
            temperature: Constants.defaultTemperature,
            maxTokens: Constants.defaultMaxTokens
        )

        // Make request
        let response: ChatCompletionResponse = try await performRequest(
            url: Constants.chatCompletionsURL,
            body: requestBody,
            apiKey: apiKey
        )

        // Extract response content
        guard let choice = response.choices.first else {
            // Remove the user message since we didn't get a valid response
            conversationHistory.removeLast()
            throw OpenAIError.emptyResponse
        }

        let assistantMessage = choice.message

        // Add assistant message to history
        conversationHistory.append(assistantMessage)

        return assistantMessage.content
    }

    /// Converts text to speech audio
    /// - Parameter text: The text to convert to speech
    /// - Returns: Audio data in AAC format
    /// - Throws: OpenAIError if the request fails
    func textToSpeech(_ text: String) async throws -> Data {
        let apiKey = try getAPIKey()

        let requestBody = TTSRequest(
            model: Constants.ttsModel,
            input: text,
            voice: Constants.ttsVoice,
            responseFormat: Constants.ttsFormat
        )

        guard let url = URL(string: Constants.ttsURL) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            throw OpenAIError.decodingError(error)
        }

        let (data, response) = try await performDataRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        // Check for error response (TTS returns audio data on success, JSON on error)
        if httpResponse.statusCode != 200 {
            let errorMessage = try? decoder.decode(APIErrorResponse.self, from: data).error.message
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        return data
    }

    // MARK: - Private Methods

    /// Gets the API key from Secrets
    private func getAPIKey() throws -> String {
        return apiKey
    }

    /// Performs a JSON API request and decodes the response
    private func performRequest<RequestBody: Encodable, ResponseBody: Decodable>(
        url: String,
        body: RequestBody,
        apiKey: String
    ) async throws -> ResponseBody {
        guard let url = URL(string: url) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw OpenAIError.decodingError(error)
        }

        let (data, response) = try await performDataRequest(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        // Handle HTTP errors
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw OpenAIError.invalidAPIKey
        default:
            // Try to decode error response
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }

        // Decode successful response
        do {
            return try decoder.decode(ResponseBody.self, from: data)
        } catch {
            throw OpenAIError.decodingError(error)
        }
    }

    /// Performs a data request with error handling
    private func performDataRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            throw OpenAIError.networkError(error)
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
}

