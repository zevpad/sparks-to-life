import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var showSession: Bool
    @State private var tab: Int = 0

    private var todaySessions: [CravingSession] {
        let start = Calendar.current.startOfDay(for: Date())
        return dataStore.sessions.filter { Calendar.current.startOfDay(for: $0.date) == start }
    }

    var body: some View {
        ZStack {
            CC.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, CC.l)
                        .padding(.top, CC.l)

                    Spacer().frame(height: CC.xl)

                    ctaButton
                        .padding(.horizontal, CC.l)

                    Spacer().frame(height: CC.xl)

                    statsRow
                        .padding(.horizontal, CC.l)

                    if dataStore.streak >= 3 {
                        Spacer().frame(height: CC.m)
                        StreakBanner(streak: dataStore.streak)
                            .padding(.horizontal, CC.l)
                    }

                    Spacer().frame(height: CC.xl)
                    tabSection
                    Spacer().frame(height: 100)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CRAVING")
                .font(.system(size: 54, weight: .black))
                .kerning(-2)
                .foregroundColor(CC.textPrimary)
            Text("CONVERTER")
                .font(.system(size: 54, weight: .black))
                .kerning(-2)
                .foregroundColor(CC.green)
                .glow(CC.green, radius: 22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button {
            withAnimation(CC.smooth) { showSession = true }
        } label: {
            HStack(spacing: CC.m) {
                Text("⚡").font(.system(size: 22))
                Text("CONVERT A CRAVING")
                    .font(.system(size: 18, weight: .black))
                    .kerning(-0.5)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(CC.green)
            .cornerRadius(CC.rL)
        }
        .glow(CC.green, radius: 20)
        .pulsingBorder(CC.green)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: CC.s) {
            StatCard(value: "\(dataStore.streak)",            label: "DAY\nSTREAK",    color: CC.purple)
            StatCard(value: "\(dataStore.sessions.count)",   label: "CONVERTED",      color: CC.green)
            StatCard(value: "\(dataStore.totalMinutesSaved)",label: "MINS\nSAVED",     color: CC.orange)
        }
    }

    // MARK: - Tabs

    private var tabSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabPill("TODAY",   0)
                tabPill("HISTORY", 1)
            }
            .padding(.horizontal, CC.l)

            Spacer().frame(height: CC.l)

            if tab == 0 { todayContent } else { historyContent }
        }
    }

    private func tabPill(_ label: String, _ idx: Int) -> some View {
        Button { withAnimation(CC.snap) { tab = idx } } label: {
            Text(label)
                .font(.system(size: 12, weight: .black))
                .kerning(0.8)
                .foregroundColor(tab == idx ? CC.green : CC.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(tab == idx ? CC.green.opacity(0.1) : Color.clear)
                .cornerRadius(CC.s)
        }
    }

    // MARK: - Today

    private var todayContent: some View {
        VStack(spacing: CC.m) {
            if todaySessions.isEmpty {
                emptyState(emoji: "🎯", title: "Nothing converted yet today.", sub: "Pause. One small action. That's all it takes.")
            } else {
                ForEach(todaySessions) { s in
                    SessionRow(session: s).padding(.horizontal, CC.l)
                }

                HStack {
                    Text("\(todaySessions.filter(\.wasSuccessful).count) wins today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(CC.textTertiary)
                    Spacer()
                    Text("\(todaySessions.reduce(0){$0+$1.minutesSaved}) min saved")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(CC.orange)
                }
                .padding(.horizontal, CC.l)
            }
        }
    }

    // MARK: - History

    private var historyContent: some View {
        VStack(spacing: CC.m) {
            if dataStore.sessions.isEmpty {
                emptyState(emoji: "📋", title: "No history yet.", sub: "Every converted craving will appear here.")
            } else {
                ForEach(dataStore.sessions.prefix(60)) { s in
                    SessionRow(session: s).padding(.horizontal, CC.l)
                }
            }
        }
    }

    private func emptyState(emoji: String, title: String, sub: String) -> some View {
        VStack(spacing: CC.m) {
            Text(emoji).font(.system(size: 48))
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(CC.textPrimary)
            Text(sub)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CC.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(CC.xxl)
        .frame(maxWidth: .infinity)
    }
}
