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
        let candidates = [
            ("theme", "mp3"), ("theme", "m4a"), ("theme", "aac"), ("theme", "wav"),
            ("Suno1_lift_the_spark", "mp3"), ("Suno1_lift_the_spark", "m4a")
        ]
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext),
               let p = try? AVAudioPlayer(contentsOf: url) {
                player = p
                player?.numberOfLoops = -1
                player?.volume = 0.65
                player?.prepareToPlay()
                return
            }
        }
        // Fallback: play the first audio file found in the bundle
        let audioExts = Set(["mp3", "m4a", "aac", "wav", "caf"])
        if let bundleURL = Bundle.main.resourceURL,
           let contents = try? FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil) {
            for url in contents where audioExts.contains(url.pathExtension.lowercased()) {
                if let p = try? AVAudioPlayer(contentsOf: url) {
                    player = p
                    player?.numberOfLoops = -1
                    player?.volume = 0.65
                    player?.prepareToPlay()
                    return
                }
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
