import Foundation

// MARK: - Action Category

enum ActionCategory: String, Codable, CaseIterable {
    case movement = "Movement"
    case breath = "Breath"
    case hydration = "Hydration"
    case distraction = "Distraction"
    case sensory = "Sensory"
    case social = "Social"
    case creative = "Creative"
    case mindfulness = "Mindfulness"

    var emoji: String {
        switch self {
        case .movement:    return "🏃"
        case .breath:      return "💨"
        case .hydration:   return "💧"
        case .distraction: return "🎯"
        case .sensory:     return "👃"
        case .social:      return "💬"
        case .creative:    return "🎨"
        case .mindfulness: return "🧘"
        }
    }
}

// MARK: - Replacement Action

struct ReplacementAction: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var category: ActionCategory
    var minutesSaved: Int
    var successCount: Int
    var useCount: Int
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, category: ActionCategory, minutesSaved: Int = 10, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.minutesSaved = minutesSaved
        self.isCustom = isCustom
        self.successCount = 0
        self.useCount = 0
    }
}

// MARK: - Craving Category

struct CravingCategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var actions: [ReplacementAction]

    init(id: UUID = UUID(), name: String, emoji: String, actions: [ReplacementAction]) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.actions = actions
    }
}

// MARK: - Craving Session

struct CravingSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let categoryName: String
    let categoryEmoji: String
    let actionName: String
    let intensityBefore: Int
    let intensityAfter: Int
    let durationSeconds: Int

    var drop: Int { max(0, intensityBefore - intensityAfter) }
    var wasSuccessful: Bool { intensityAfter < intensityBefore }
    var minutesSaved: Int { max(1, durationSeconds / 60) }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        categoryName: String,
        categoryEmoji: String,
        actionName: String,
        intensityBefore: Int,
        intensityAfter: Int,
        durationSeconds: Int
    ) {
        self.id = id
        self.date = date
        self.categoryName = categoryName
        self.categoryEmoji = categoryEmoji
        self.actionName = actionName
        self.intensityBefore = intensityBefore
        self.intensityAfter = intensityAfter
        self.durationSeconds = durationSeconds
    }
}

// MARK: - Action Weight (learning data)

struct ActionWeight: Codable {
    var totalDrop: Double
    var useCount: Int
    var successCount: Int

    init() {
        totalDrop = 0
        useCount = 0
        successCount = 0
    }

    var averageDrop: Double {
        useCount > 0 ? totalDrop / Double(useCount) : 0
    }

    var successRate: Double {
        useCount > 0 ? Double(successCount) / Double(useCount) : 0.5
    }

    // Logarithmic boost for repeated use without over-weighting
    var usageFactor: Double {
        1.0 + log(Double(useCount + 1)) * 0.1
    }

    var score: Double {
        averageDrop * successRate * usageFactor
    }
}
