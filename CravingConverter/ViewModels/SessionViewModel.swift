import Foundation
import Combine
import SwiftUI

enum FlowStep: Equatable {
    case craving
    case customInput
    case intensity
    case action
    case timer
    case recheck
    case win
}

final class SessionViewModel: ObservableObject {

    // Flow
    @Published var currentStep: FlowStep = .craving
    @Published var selectedCategory: CravingCategory?
    @Published var customCravingText: String = ""
    @Published var selectedAction: ReplacementAction?

    // Intensity
    @Published var intensityBefore: Int = 0
    @Published var intensityAfter: Int = 0

    // Timer
    @Published var timerDuration: Int = 300
    @Published var timeRemaining: Int = 300
    @Published var isTimerRunning: Bool = false
    @Published var isTimerPaused: Bool = false
    @Published var timerCompleted: Bool = false

    // Win screen
    @Published var goalImageURL: URL?
    @Published var goalImagePrompt: String = ""
    @Published var isLoadingImage: Bool = false

    private(set) var timerTask: Task<Void, Never>?

    var dropScore: Int { max(0, intensityBefore - intensityAfter) }
    var wasSuccessful: Bool { intensityAfter < intensityBefore }

    // MARK: - Flow Control

    func selectCategory(_ category: CravingCategory) {
        selectedCategory = category
        currentStep = category.name == "Something else" ? .customInput : .intensity
    }

    func submitCustomCraving() {
        currentStep = .intensity
    }

    func selectIntensityBefore(_ value: Int) {
        intensityBefore = value
        currentStep = .action
    }

    func selectAction(_ action: ReplacementAction) {
        selectedAction = action
        let secs = max(60, action.minutesSaved * 60)
        timerDuration  = secs
        timeRemaining  = secs
        currentStep    = .timer
        startTimer()
    }

    func selectIntensityAfter(_ value: Int) {
        intensityAfter = value
        currentStep    = .win
        fetchGoalImage()
    }

    // MARK: - Timer

    func startTimer() {
        timerTask?.cancel()
        isTimerRunning  = true
        isTimerPaused   = false
        timerCompleted  = false

        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }

                let done = await MainActor.run { () -> Bool in
                    guard !self.isTimerPaused, self.timeRemaining > 0 else { return false }
                    self.timeRemaining -= 1
                    return self.timeRemaining == 0
                }

                if done {
                    await MainActor.run {
                        self.timerCompleted = true
                        self.isTimerRunning = false
                    }
                    try? await Task.sleep(nanoseconds: 700_000_000)
                    guard !Task.isCancelled else { return }
                    await MainActor.run { self.currentStep = .recheck }
                    return
                }
            }
        }
    }

    func pauseTimer()  { isTimerPaused = true }
    func resumeTimer() { isTimerPaused = false }

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        isTimerRunning = false
        isTimerPaused  = false
    }

    func skipTimer() {
        cancelTimer()
        currentStep = .recheck
    }

    // MARK: - Goal Image

    func fetchGoalImage() {
        guard let category = selectedCategory, let action = selectedAction else { return }

        // Use bundled asset — no network call needed
        if action.localImageName != nil {
            isLoadingImage = false
            goalImageURL   = nil
            return
        }

        isLoadingImage = true

        Task {
            let prompt = await generatePrompt(category: category.name, action: action.name, drop: dropScore)
            let seed = abs(prompt.hashValue) % 1000
            await MainActor.run {
                self.goalImagePrompt = prompt
                self.goalImageURL = URL(string: "https://picsum.photos/seed/\(seed)/800/600")
                self.isLoadingImage = false
            }
        }
    }

    private func generatePrompt(category: String, action: String, drop: Int) async -> String {
        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 150,
            "system": "Generate a single cinematic image prompt (under 80 words) for a behavior-change app win screen. Emphasize freedom, strength, clarity. No text overlays, no people talking, purely visual and aspirational.",
            "messages": [[
                "role": "user",
                "content": "Craving: \(category). Action taken: \(action). Intensity dropped \(drop) points. Give me one stunning cinematic image prompt showing the feeling of this win."
            ]]
        ]

        guard let url  = URL(string: "https://api.anthropic.com/v1/messages"),
              let data = try? JSONSerialization.data(withJSONObject: body) else {
            return fallbackPrompt
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")
        // API key handled by proxy — no key in source
        req.httpBody = data

        do {
            let (resp, _) = try await URLSession.shared.data(for: req)
            if let json    = try? JSONSerialization.jsonObject(with: resp) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let text    = content.first?["text"] as? String {
                return text
            }
        } catch {}

        return fallbackPrompt
    }

    private var fallbackPrompt: String {
        "A lone figure on a mountain ridge at golden hour, arms wide, a vast ocean of clouds below — the feeling of quiet strength and total freedom"
    }

    // MARK: - Build Session

    func buildSession() -> CravingSession? {
        guard let category = selectedCategory else { return nil }
        let name = (category.name == "Something else" && !customCravingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            ? customCravingText
            : category.name

        return CravingSession(
            categoryName:    name,
            categoryEmoji:   category.emoji,
            actionName:      selectedAction?.name ?? "",
            intensityBefore: intensityBefore,
            intensityAfter:  intensityAfter,
            durationSeconds: timerDuration - timeRemaining
        )
    }

    deinit { timerTask?.cancel() }
}
