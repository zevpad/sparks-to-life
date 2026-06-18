import Foundation
import AVFoundation
import Combine

final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()

    @Published var isPlaying: Bool = false

    private var player: AVAudioPlayer?

    private init() {
        configureSession()
        loadTrack()
    }

    // MARK: - Setup

    private func configureSession() {
        do {
            // .ambient: mixes with other apps' audio, respects silent switch
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }

    private func loadTrack() {
        // Looks for: theme.mp3, theme.m4a, theme.aac, theme.wav (add your Suno file with one of these names)
        let candidates = [("theme", "mp3"), ("theme", "m4a"), ("theme", "aac"), ("theme", "wav")]
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.numberOfLoops = -1   // loop forever
                    player?.volume = 0.65
                    player?.prepareToPlay()
                } catch {}
                return
            }
        }
    }

    // MARK: - Controls

    func play() {
        guard player != nil else { return }
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func toggle() {
        isPlaying ? pause() : play()
    }

    func setVolume(_ v: Float) {
        player?.volume = max(0, min(1, v))
    }
}
