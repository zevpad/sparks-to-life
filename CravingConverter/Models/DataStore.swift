import Foundation
import Combine
import UserNotifications

final class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var sessions: [CravingSession] = []
    @Published var categories: [CravingCategory] = []
    @Published var actionWeights: [UUID: ActionWeight] = [:]
    @Published var streak: Int = 0
    @Published var totalMinutesSaved: Int = 0

    private let sessionsKey   = "cc_sessions_v2"
    private let weightsKey    = "cc_weights_v2"
    private let categoriesKey = "cc_categories_v2"

    private init() {
        loadData()
        if categories.isEmpty {
            categories = Self.defaultCategories()
        } else {
            mergeDefaultCategories()
        }
        recalculateStreak()
        recalculateTotals()
    }

    // Injects any new default categories added after initial install
    private func mergeDefaultCategories() {
        let existingNames = Set(categories.map { $0.name })
        let missing = Self.defaultCategories().filter { !existingNames.contains($0.name) }
        if !missing.isEmpty {
            categories.append(contentsOf: missing)
            saveData()
        }
    }

    // MARK: - Smart Sorting

    func sortedActions(for category: CravingCategory) -> [ReplacementAction] {
        category.actions.sorted { a, b in
            let sa = actionWeights[a.id]?.score ?? 0
            let sb = actionWeights[b.id]?.score ?? 0
            return sa > sb
        }
    }

    // MARK: - Session Completion

    func completeSession(_ session: CravingSession, categoryId: UUID, actionId: UUID) {
        sessions.insert(session, at: 0)
        updateWeight(actionId: actionId, session: session)

        if let ci = categories.firstIndex(where: { $0.id == categoryId }),
           let ai = categories[ci].actions.firstIndex(where: { $0.id == actionId }) {
            categories[ci].actions[ai].useCount += 1
            if session.wasSuccessful { categories[ci].actions[ai].successCount += 1 }
        }

        recalculateStreak()
        recalculateTotals()
        saveData()
        scheduleReminderIfNeeded()
    }

    private func updateWeight(actionId: UUID, session: CravingSession) {
        var w = actionWeights[actionId] ?? ActionWeight()
        w.useCount += 1
        w.totalDrop += Double(session.drop)
        if session.wasSuccessful { w.successCount += 1 }
        actionWeights[actionId] = w
    }

    // MARK: - Streak

    func recalculateStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var date = today
        var count = 0

        let days = Set(sessions.map { cal.startOfDay(for: $0.date) })
        while days.contains(date) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        streak = count
    }

    private func recalculateTotals() {
        totalMinutesSaved = sessions.reduce(0) { $0 + $1.minutesSaved }
    }

    var momentum: String {
        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -7, to: Date())!
        let recent = sessions.filter { $0.date > cutoff }.count
        switch recent {
        case 8...: return "STRONG"
        case 4...: return "RISING"
        case 1...: return "STEADY"
        default:   return "BEGIN"
        }
    }

    var hoursReclaimed: Int { totalMinutesSaved / 60 }

    // MARK: - Persistence

    // MARK: - Custom Categories

    func addCustomCategory(name: String, emoji: String) {
        let cat = CravingCategory(
            name: name,
            emoji: emoji.isEmpty ? "✨" : String(emoji.prefix(2)),
            actions: Self.starterActions(),
            isCustom: true
        )
        categories.append(cat)
        saveData()
    }

    func deleteCustomCategory(_ id: UUID) {
        categories.removeAll { $0.id == id && $0.isCustom }
        saveData()
    }

    func deleteCategory(_ id: UUID) {
        categories.removeAll { $0.id == id }
        saveData()
    }

    func deleteSession(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        recalculateStreak()
        recalculateTotals()
        saveData()
    }

    private static func starterActions() -> [ReplacementAction] {
        [
            ReplacementAction(name: "Take 5 deep breaths",    category: .breath,      minutesSaved: 5),
            ReplacementAction(name: "Drink a glass of water", category: .hydration,   minutesSaved: 5),
            ReplacementAction(name: "Go for a short walk",    category: .movement,    minutesSaved: 10),
            ReplacementAction(name: "Write it down",          category: .creative,    minutesSaved: 5),
            ReplacementAction(name: "Sit with it, 60 sec",    category: .mindfulness, minutesSaved: 3),
        ]
    }

    // MARK: - Custom Actions

    @discardableResult
    func addCustomAction(name: String, to categoryId: UUID) -> ReplacementAction? {
        guard let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return nil }
        let action = ReplacementAction(name: name, category: .distraction, minutesSaved: 5, isCustom: true)
        categories[idx].actions.append(action)
        saveData()
        return action
    }

    func deleteCustomAction(_ actionId: UUID, from categoryId: UUID) {
        guard let ci = categories.firstIndex(where: { $0.id == categoryId }),
              let ai = categories[ci].actions.firstIndex(where: { $0.id == actionId && $0.isCustom })
        else { return }
        categories[ci].actions.remove(at: ai)
        actionWeights.removeValue(forKey: actionId)
        saveData()
    }

    func deleteAction(_ actionId: UUID, from categoryId: UUID) {
        guard let ci = categories.firstIndex(where: { $0.id == categoryId }),
              let ai = categories[ci].actions.firstIndex(where: { $0.id == actionId })
        else { return }
        categories[ci].actions.remove(at: ai)
        actionWeights.removeValue(forKey: actionId)
        saveData()
    }

    // MARK: - Persistence

    private func saveData() {
        let enc = JSONEncoder()
        if let d = try? enc.encode(sessions)       { UserDefaults.standard.set(d, forKey: sessionsKey) }
        if let d = try? enc.encode(actionWeights)  { UserDefaults.standard.set(d, forKey: weightsKey) }
        if let d = try? enc.encode(categories)     { UserDefaults.standard.set(d, forKey: categoriesKey) }
    }

    private func loadData() {
        let dec = JSONDecoder()
        if let d = UserDefaults.standard.data(forKey: sessionsKey),
           let v = try? dec.decode([CravingSession].self, from: d)     { sessions = v }
        if let d = UserDefaults.standard.data(forKey: weightsKey),
           let v = try? dec.decode([UUID: ActionWeight].self, from: d) { actionWeights = v }
        if let d = UserDefaults.standard.data(forKey: categoriesKey),
           let v = try? dec.decode([CravingCategory].self, from: d)    { categories = v }
    }

    // MARK: - Notifications

    func scheduleReminderIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            center.removePendingNotificationRequests(withIdentifiers: ["cc_daily_v2"])

            let content = UNMutableNotificationContent()
            content.title = "Convert a craving."
            content.body  = "One action. That's all it takes."
            content.sound = .default

            var comps = DateComponents()
            comps.hour   = 20
            comps.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            center.add(UNNotificationRequest(identifier: "cc_daily_v2", content: content, trigger: trigger))
        }
    }

    // MARK: - Default Data

    static func defaultCategories() -> [CravingCategory] {
        [
            CravingCategory(name: "Sugar / Junk Food", emoji: "🍭", actions: [
                ReplacementAction(name: "Drink a full glass of water",  category: .hydration,   minutesSaved: 5),
                ReplacementAction(name: "Do 10 jumping jacks",          category: .movement,    minutesSaved: 3),
                ReplacementAction(name: "Brush your teeth",             category: .sensory,     minutesSaved: 5),
                ReplacementAction(name: "Eat a piece of fruit",         category: .hydration,   minutesSaved: 5),
                ReplacementAction(name: "Take 5 deep breaths",          category: .breath,      minutesSaved: 3),
                ReplacementAction(name: "Chew sugar-free gum",          category: .sensory,     minutesSaved: 5),
                ReplacementAction(name: "Go for a 5-min walk",          category: .movement,    minutesSaved: 15),
            ]),
            CravingCategory(name: "Alcohol", emoji: "🍺", actions: [
                ReplacementAction(name: "Sparkling water with citrus",   category: .hydration,   minutesSaved: 20),
                ReplacementAction(name: "Call someone you trust",        category: .social,      minutesSaved: 30),
                ReplacementAction(name: "Go for a walk outside",         category: .movement,    minutesSaved: 20),
                ReplacementAction(name: "4-7-8 breathing",               category: .breath,      minutesSaved: 10),
                ReplacementAction(name: "Write what's on your mind",     category: .creative,    minutesSaved: 15),
                ReplacementAction(name: "Make herbal tea",               category: .sensory,     minutesSaved: 15),
            ]),
            CravingCategory(name: "Nicotine", emoji: "🚬", actions: [
                ReplacementAction(name: "10 slow deep breaths",          category: .breath,      minutesSaved: 10),
                ReplacementAction(name: "Cold water, drink slowly",      category: .hydration,   minutesSaved: 5),
                ReplacementAction(name: "2-min stretch",                 category: .movement,    minutesSaved: 5),
                ReplacementAction(name: "Chew gum or a toothpick",       category: .sensory,     minutesSaved: 10),
                ReplacementAction(name: "Step outside, fresh air",       category: .breath,      minutesSaved: 5),
                ReplacementAction(name: "Hold an ice cube",              category: .sensory,     minutesSaved: 3),
            ]),
            CravingCategory(name: "Phone / Social Media", emoji: "📱", actions: [
                ReplacementAction(name: "Phone face-down for 5 min",     category: .mindfulness, minutesSaved: 30),
                ReplacementAction(name: "Body scan meditation",          category: .mindfulness, minutesSaved: 10),
                ReplacementAction(name: "Write 3 things you're grateful for", category: .creative, minutesSaved: 10),
                ReplacementAction(name: "Do 10 push-ups",                category: .movement,    minutesSaved: 5),
                ReplacementAction(name: "Read one page of a book",       category: .distraction, minutesSaved: 15),
                ReplacementAction(name: "Tidy one small area",           category: .distraction, minutesSaved: 10),
            ]),
            CravingCategory(name: "Stress Eating", emoji: "😤", actions: [
                ReplacementAction(name: "Box breathing (4-4-4-4)",       category: .breath,      minutesSaved: 10),
                ReplacementAction(name: "10-min walk",                   category: .movement,    minutesSaved: 20),
                ReplacementAction(name: "Write down what's stressing you", category: .creative,  minutesSaved: 10),
                ReplacementAction(name: "Progressive muscle relax",      category: .mindfulness, minutesSaved: 10),
                ReplacementAction(name: "Text a friend",                 category: .social,      minutesSaved: 15),
                ReplacementAction(name: "Herbal tea, mindfully",         category: .sensory,     minutesSaved: 10),
            ]),
            CravingCategory(name: "Caffeine", emoji: "☕", actions: [
                ReplacementAction(name: "Large glass of water",          category: .hydration,   minutesSaved: 5),
                ReplacementAction(name: "Splash cold water on face",     category: .sensory,     minutesSaved: 3),
                ReplacementAction(name: "10-min brisk walk",             category: .movement,    minutesSaved: 15),
                ReplacementAction(name: "20 jumping jacks",              category: .movement,    minutesSaved: 5),
                ReplacementAction(name: "Green tea instead",             category: .sensory,     minutesSaved: 10),
                ReplacementAction(name: "5 energizing deep breaths",     category: .breath,      minutesSaved: 5),
            ]),
            CravingCategory(name: "Gambling", emoji: "🎰", actions: [
                ReplacementAction(name: "Call your support person",      category: .social,      minutesSaved: 60),
                ReplacementAction(name: "Run or fast walk",              category: .movement,    minutesSaved: 30),
                ReplacementAction(name: "Write your reasons to stop",    category: .creative,    minutesSaved: 15),
                ReplacementAction(name: "10-min guided meditation",      category: .mindfulness, minutesSaved: 20),
                ReplacementAction(name: "Mobile puzzle game",            category: .distraction, minutesSaved: 20),
            ]),
            CravingCategory(name: "Something else", emoji: "✏️", actions: [
                ReplacementAction(name: "Take 5 deep breaths",           category: .breath,      minutesSaved: 5),
                ReplacementAction(name: "Drink a glass of water",        category: .hydration,   minutesSaved: 5),
                ReplacementAction(name: "Go for a short walk",           category: .movement,    minutesSaved: 10),
                ReplacementAction(name: "Quick stretch",                 category: .movement,    minutesSaved: 5),
                ReplacementAction(name: "Write it down",                 category: .creative,    minutesSaved: 10),
                ReplacementAction(name: "Sit with it for 60 seconds",    category: .mindfulness, minutesSaved: 5),
            ]),
            CravingCategory(name: "Visualization Aids", emoji: "🌟", actions: [
                ReplacementAction(name: "Tree of Life meditation",        category: .mindfulness, minutesSaved: 10, localImageName: "Aleph"),
                ReplacementAction(name: "Every Craving is Energy",        category: .mindfulness, minutesSaved: 5,  localImageName: "Icrave"),
                ReplacementAction(name: "Visualize your ideal self",      category: .mindfulness, minutesSaved: 5),
                ReplacementAction(name: "Sacred geometry focus",          category: .mindfulness, minutesSaved: 10),
                ReplacementAction(name: "Breath of light visualization",  category: .breath,      minutesSaved: 5),
                ReplacementAction(name: "Body of light meditation",       category: .mindfulness, minutesSaved: 8),
            ]),
            CravingCategory(name: "Emotional Escape", emoji: "💭", actions: [
                ReplacementAction(name: "Name the emotion out loud",           category: .mindfulness, minutesSaved: 3),
                ReplacementAction(name: "Write what you're feeling",           category: .creative,    minutesSaved: 10),
                ReplacementAction(name: "Box breathing (4-4-4-4)",             category: .breath,      minutesSaved: 5),
                ReplacementAction(name: "Call someone you trust",              category: .social,      minutesSaved: 20),
                ReplacementAction(name: "10-min walk outside",                 category: .movement,    minutesSaved: 15),
                ReplacementAction(name: "Body scan meditation",                category: .mindfulness, minutesSaved: 8),
                ReplacementAction(name: "Cold water on your face",             category: .sensory,     minutesSaved: 2),
            ]),
            CravingCategory(name: "Dopamine Seeking", emoji: "📲", actions: [
                ReplacementAction(name: "Phone face-down for 10 min",          category: .mindfulness, minutesSaved: 30),
                ReplacementAction(name: "Write 3 things going well",           category: .creative,    minutesSaved: 5),
                ReplacementAction(name: "Do 20 jumping jacks",                 category: .movement,    minutesSaved: 5),
                ReplacementAction(name: "Drink water, breathe slowly",         category: .hydration,   minutesSaved: 3),
                ReplacementAction(name: "Read one page of a book",             category: .distraction, minutesSaved: 10),
                ReplacementAction(name: "5-min guided breathing",              category: .breath,      minutesSaved: 5),
            ]),
            CravingCategory(name: "Procrastination", emoji: "⏳", actions: [
                ReplacementAction(name: "2-min rule: start anything now",      category: .distraction, minutesSaved: 5),
                ReplacementAction(name: "Write the single next step",          category: .creative,    minutesSaved: 3),
                ReplacementAction(name: "Set a 25-min focus timer",            category: .mindfulness, minutesSaved: 25),
                ReplacementAction(name: "5 deep breaths, then begin",          category: .breath,      minutesSaved: 3),
                ReplacementAction(name: "Clear your workspace",                category: .distraction, minutesSaved: 5),
                ReplacementAction(name: "Say out loud: 'I do hard things'",   category: .mindfulness, minutesSaved: 1),
            ]),
            CravingCategory(name: "Seeking Validation", emoji: "🫂", actions: [
                ReplacementAction(name: "Write 3 things you value in yourself", category: .creative,    minutesSaved: 5),
                ReplacementAction(name: "Do something creative, just for you",  category: .creative,    minutesSaved: 15),
                ReplacementAction(name: "5 deep breaths, hand on heart",        category: .breath,      minutesSaved: 3),
                ReplacementAction(name: "Call someone you genuinely care about", category: .social,     minutesSaved: 15),
                ReplacementAction(name: "Walk outside without your phone",       category: .movement,   minutesSaved: 10),
                ReplacementAction(name: "Body scan: feel your own presence",     category: .mindfulness, minutesSaved: 5),
            ]),
        ]
    }
}
