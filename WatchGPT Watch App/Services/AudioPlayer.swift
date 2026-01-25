import AVFoundation
import Foundation

/// Audio player for TTS playback on Apple Watch
@Observable
final class AudioPlayer: NSObject {
    // MARK: - Singleton

    static let shared = AudioPlayer()

    // MARK: - Properties

    /// Currently playing message ID
    private(set) var playingMessageID: UUID?

    /// Whether audio is currently playing
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?

    // MARK: - Initialization

    private override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Public Methods

    /// Plays audio data for a specific message
    /// - Parameters:
    ///   - data: Audio data (AAC format)
    ///   - messageID: ID of the message being played
    func play(data: Data, for messageID: UUID) throws {
        stop()

        do {
            try activateAudioSession()

            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            playingMessageID = messageID

            if audioPlayer?.play() != true {
                throw AudioPlayerError.playbackFailed
            }
        } catch {
            playingMessageID = nil
            throw error
        }
    }

    /// Stops current playback
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        playingMessageID = nil
        deactivateAudioSession()
    }

    /// Checks if a specific message is currently playing
    func isPlaying(messageID: UUID) -> Bool {
        playingMessageID == messageID && isPlaying
    }

    // MARK: - Private Methods

    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
    }

    private func activateAudioSession() throws {
        try audioSession?.setCategory(.playback, mode: .default)
        try audioSession?.setActive(true)
    }

    private func deactivateAudioSession() {
        try? audioSession?.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Delegate callbacks may come from background thread - dispatch to main
        DispatchQueue.main.async { [weak self] in
            self?.playingMessageID = nil
            self?.deactivateAudioSession()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        // Delegate callbacks may come from background thread - dispatch to main
        DispatchQueue.main.async { [weak self] in
            self?.playingMessageID = nil
            self?.deactivateAudioSession()
        }
    }
}

// MARK: - Errors

enum AudioPlayerError: LocalizedError {
    case playbackFailed

    var errorDescription: String? {
        switch self {
        case .playbackFailed:
            return "Failed to play audio."
        }
    }
}
