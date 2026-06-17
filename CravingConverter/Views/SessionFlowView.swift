import SwiftUI

// MARK: - Container

struct SessionFlowView: View {
    @EnvironmentObject var dataStore: DataStore
    @StateObject private var vm = SessionViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ZStack {
                CC.bg.ignoresSafeArea()
                stepView
                    .animation(CC.smooth, value: vm.currentStep)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if vm.currentStep != .win { backButton }
                }
                ToolbarItem(placement: .principal) {
                    if vm.currentStep != .win { progressDots }
                }
            }
            .toolbarBackground(CC.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var stepView: some View {
        switch vm.currentStep {
        case .craving:
            CravingPickerView(vm: vm)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .customInput:
            CustomCravingView(vm: vm)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .intensity:
            IntensityStepView(vm: vm, isAfter: false)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .action:
            ActionPickerView(vm: vm)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .timer:
            TimerView(vm: vm)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .recheck:
            IntensityStepView(vm: vm, isAfter: true)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal:   .move(edge: .leading).combined(with: .opacity)))
        case .win:
            WinView(vm: vm, isPresented: $isPresented)
                .transition(.asymmetric(insertion: .scale(scale: 0.92).combined(with: .opacity),
                                        removal:   .opacity))
        }
    }

    private var progressDots: some View {
        let steps: [FlowStep] = [.craving, .intensity, .action, .timer, .recheck, .win]
        let idx = steps.firstIndex(of: vm.currentStep) ?? 0
        return HStack(spacing: 5) {
            ForEach(0..<steps.count, id: \.self) { i in
                Circle()
                    .fill(i <= idx ? CC.green : CC.textTertiary.opacity(0.3))
                    .frame(width: i == idx ? 8 : 5, height: i == idx ? 8 : 5)
                    .animation(CC.snap, value: idx)
            }
        }
    }

    private var backButton: some View {
        Button {
            withAnimation(CC.smooth) {
                switch vm.currentStep {
                case .craving:     isPresented = false
                case .customInput: vm.currentStep = .craving
                case .intensity:   vm.currentStep = (vm.selectedCategory?.name == "Something else") ? .customInput : .craving
                case .action:      vm.currentStep = .intensity
                case .timer:       vm.cancelTimer(); vm.currentStep = .action
                case .recheck:     vm.currentStep = .timer
                case .win:         break
                }
            }
        } label: {
            Image(systemName: vm.currentStep == .craving ? "xmark" : "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CC.textSecondary)
        }
    }
}

// MARK: - Craving Picker

struct CravingPickerView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var vm: SessionViewModel

    let cols = [GridItem(.flexible(), spacing: CC.m), GridItem(.flexible(), spacing: CC.m)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CC.xl) {
                PageHeader("What's\ncalling you?", subtitle: "Pick the closest match.")
                    .padding(.horizontal, CC.l)
                    .padding(.top, CC.m)

                LazyVGrid(columns: cols, spacing: CC.m) {
                    ForEach(dataStore.categories) { cat in
                        cravingCell(cat)
                    }
                }
                .padding(.horizontal, CC.l)

                Spacer().frame(height: CC.xxl)
            }
        }
    }

    private func cravingCell(_ cat: CravingCategory) -> some View {
        let on = vm.selectedCategory?.id == cat.id
        return Button {
            withAnimation(CC.snap) { vm.selectCategory(cat) }
        } label: {
            VStack(spacing: CC.s) {
                Text(cat.emoji).font(.system(size: 38))
                Text(cat.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(on ? .black : CC.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .background(on ? CC.green : CC.card)
            .cornerRadius(CC.rL)
            .overlay(
                RoundedRectangle(cornerRadius: CC.rL)
                    .stroke(on ? CC.green : CC.border, lineWidth: 1.5)
            )
            .scaleEffect(on ? 1.04 : 1)
        }
        .glow(CC.green, radius: on ? 14 : 0)
    }
}

// MARK: - Custom Craving

struct CustomCravingView: View {
    @ObservedObject var vm: SessionViewModel
    @FocusState private var focused: Bool

    var trimmed: String { vm.customCravingText.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: CC.xl) {
            PageHeader("Name it.", subtitle: "What's the craving?")
                .padding(.horizontal, CC.l)
                .padding(.top, CC.m)

            VStack(spacing: CC.m) {
                TextField("e.g. late-night snack, junk food scroll...",
                          text: Binding(get: { vm.customCravingText },
                                        set: { vm.customCravingText = $0 }),
                          axis: .vertical)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(CC.textPrimary)
                    .padding(CC.m)
                    .background(CC.card)
                    .cornerRadius(CC.rM)
                    .overlay(
                        RoundedRectangle(cornerRadius: CC.rM)
                            .stroke(focused ? CC.green : CC.border, lineWidth: 1.5)
                    )
                    .focused($focused)
                    .tint(CC.green)

                PrimaryButton(title: "Continue →", color: CC.green, action: { vm.submitCustomCraving() }, isEnabled: !trimmed.isEmpty)
            }
            .padding(.horizontal, CC.l)

            Spacer()
        }
        .onAppear { focused = true }
    }
}

// MARK: - Intensity Step (Before & After)

struct IntensityStepView: View {
    @ObservedObject var vm: SessionViewModel
    let isAfter: Bool
    @State private var local: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: CC.xl) {
                    VStack(alignment: .leading, spacing: CC.s) {
                        PageHeader(
                            isAfter ? "How intense\nis it now?" : "How intense\nis the craving?",
                            subtitle: isAfter ? "Be honest. Any drop counts." : "Rate 1 (mild) → 10 (peak)."
                        )
                        if isAfter, let action = vm.selectedAction {
                            Text("After: \(action.name)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(CC.textTertiary)
                        }
                    }
                    .padding(.horizontal, CC.l)
                    .padding(.top, CC.m)

                    IntensityPicker(selected: local, onSelect: { local = $0 })
                        .padding(.horizontal, CC.l)

                    Spacer().frame(height: CC.xxl)
                }
            }

            VStack(spacing: CC.m) {
                PrimaryButton(
                    title: isAfter ? "See results →" : "Continue →",
                    color: CC.green,
                    action: {
                        withAnimation(CC.smooth) {
                            if isAfter { vm.selectIntensityAfter(local) }
                            else        { vm.selectIntensityBefore(local) }
                        }
                    },
                    isEnabled: local > 0
                )
            }
            .padding(.horizontal, CC.l)
            .padding(.bottom, CC.xl)
            .background(CC.bg.shadow(color: .black.opacity(0.6), radius: 20, y: -8))
        }
        .onAppear { local = isAfter ? vm.intensityAfter : vm.intensityBefore }
    }
}

// MARK: - Action Picker

struct ActionPickerView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var vm: SessionViewModel

    private var actions: [ReplacementAction] {
        guard let cat = vm.selectedCategory else { return [] }
        return dataStore.sortedActions(for: cat)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CC.l) {
                VStack(alignment: .leading, spacing: CC.s) {
                    PageHeader("Pick one action.", subtitle: "Do it for the timer. Just one.")
                    if let cat = vm.selectedCategory {
                        Text("\(cat.emoji)  \(cat.name)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(CC.textTertiary)
                    }
                }
                .padding(.horizontal, CC.l)
                .padding(.top, CC.m)

                VStack(spacing: CC.s) {
                    ForEach(Array(actions.enumerated()), id: \.element.id) { idx, action in
                        actionRow(action, isTop: idx == 0 && (dataStore.actionWeights[action.id]?.useCount ?? 0) > 0)
                    }
                }
                .padding(.horizontal, CC.l)

                Spacer().frame(height: CC.xxl)
            }
        }
    }

    private func actionRow(_ action: ReplacementAction, isTop: Bool) -> some View {
        Button {
            withAnimation(CC.snap) { vm.selectAction(action) }
        } label: {
            HStack(spacing: CC.m) {
                Text(action.category.emoji)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(CC.cardElevated)
                    .cornerRadius(CC.s)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: CC.s) {
                        Text(action.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(CC.textPrimary)
                            .multilineTextAlignment(.leading)
                        if isTop {
                            Text("works for you")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(CC.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CC.green.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    Text("\(action.minutesSaved) min · \(action.category.rawValue)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CC.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(CC.textTertiary)
            }
            .padding(CC.m)
            .background(CC.card)
            .cornerRadius(CC.rM)
            .overlay(
                RoundedRectangle(cornerRadius: CC.rM)
                    .stroke(isTop ? CC.green.opacity(0.3) : CC.border, lineWidth: 1)
            )
        }
        .glow(CC.green, radius: isTop ? 6 : 0)
    }
}

// MARK: - Timer

struct TimerView: View {
    @ObservedObject var vm: SessionViewModel

    private var progress: Double {
        vm.timerDuration > 0 ? Double(vm.timeRemaining) / Double(vm.timerDuration) : 0
    }

    private var ringColor: Color {
        progress > 0.5 ? CC.green : progress > 0.25 ? CC.yellow : CC.orange
    }

    var body: some View {
        VStack(spacing: CC.xl) {
            if let action = vm.selectedAction {
                VStack(spacing: CC.s) {
                    Text("Do it now.")
                        .font(.system(size: 34, weight: .black))
                        .kerning(-1)
                        .foregroundColor(CC.textPrimary)
                    Text(action.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CC.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CC.l)
                }
                .padding(.top, CC.m)
            }

            // Ring
            ZStack {
                Circle()
                    .stroke(CC.card, lineWidth: 18)
                    .frame(width: 220, height: 220)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [CC.green, CC.yellow, CC.orange]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                    .glow(ringColor, radius: 10)

                VStack(spacing: 4) {
                    Text(fmt(vm.timeRemaining))
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .kerning(-2)
                        .foregroundColor(CC.textPrimary)

                    Text(vm.isTimerPaused ? "PAUSED" : "remaining")
                        .font(.system(size: 12, weight: vm.isTimerPaused ? .black : .medium))
                        .kerning(vm.isTimerPaused ? 1 : 0)
                        .foregroundColor(vm.isTimerPaused ? CC.orange : CC.textTertiary)
                        .animation(CC.snap, value: vm.isTimerPaused)
                }
            }

            // Controls
            HStack(spacing: CC.m) {
                GhostButton(title: vm.isTimerPaused ? "Resume" : "Pause") {
                    vm.isTimerPaused ? vm.resumeTimer() : vm.pauseTimer()
                }
                PrimaryButton(title: "Done early →", color: CC.orange) {
                    vm.skipTimer()
                }
            }
            .padding(.horizontal, CC.l)

            Button { vm.skipTimer() } label: {
                Text("Skip timer")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CC.textTertiary)
            }

            Spacer()
        }
    }

    private func fmt(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Win

struct WinView: View {
    @ObservedObject var vm: SessionViewModel
    @EnvironmentObject var dataStore: DataStore
    @Binding var isPresented: Bool

    @State private var showConfetti = false
    @State private var ready = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: CC.xl) {
                    // Hero text
                    VStack(spacing: CC.m) {
                        Text(vm.wasSuccessful ? "That's a real win." : "You showed up.")
                            .font(.system(size: 38, weight: .black))
                            .kerning(-1.5)
                            .foregroundColor(CC.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(vm.wasSuccessful
                            ? "Craving converted. Down \(vm.dropScore) points."
                            : "Doing the action matters. Keep going.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(CC.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, CC.l)
                    .padding(.top, CC.xl)
                    .opacity(ready ? 1 : 0)
                    .offset(y: ready ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: ready)

                    // Streak milestone
                    if dataStore.streak >= 3 {
                        StreakBanner(streak: dataStore.streak)
                            .padding(.horizontal, CC.l)
                            .opacity(ready ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.25), value: ready)
                    }

                    // Goal image
                    goalImage
                        .padding(.horizontal, CC.l)
                        .opacity(ready ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: ready)

                    // Session card
                    if let session = vm.buildSession() {
                        WinSummaryCard(session: session)
                            .padding(.horizontal, CC.l)
                            .opacity(ready ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.45), value: ready)
                    }

                    // Done
                    PrimaryButton(title: "Back to home", color: CC.green) {
                        if let session = vm.buildSession() {
                            dataStore.completeSession(
                                session,
                                categoryId: vm.selectedCategory?.id ?? UUID(),
                                actionId:   vm.selectedAction?.id   ?? UUID()
                            )
                        }
                        isPresented = false
                    }
                    .padding(.horizontal, CC.l)
                    .padding(.bottom, CC.xxl)
                    .opacity(ready ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.55), value: ready)
                }
            }

            if showConfetti {
                ConfettiView().ignoresSafeArea()
            }
        }
        .onAppear {
            guard !ready else { return }
            ready = true
            showConfetti = true
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run { showConfetti = false }
            }
        }
    }

    @ViewBuilder
    private var goalImage: some View {
        if vm.isLoadingImage {
            ZStack {
                RoundedRectangle(cornerRadius: CC.rL).fill(CC.card).frame(height: 200)
                VStack(spacing: CC.m) {
                    ProgressView().tint(CC.green)
                    Text("Generating your moment…")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(CC.textTertiary)
                }
            }
        } else if let url = vm.goalImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: CC.rL))
                        .overlay(RoundedRectangle(cornerRadius: CC.rL).stroke(CC.green.opacity(0.3), lineWidth: 1))
                        .glow(CC.green, radius: 6)
                default:
                    fallbackCard
                }
            }
        } else {
            fallbackCard
        }
    }

    private var fallbackCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CC.rL).fill(CC.card).frame(height: 180)
            VStack(spacing: CC.s) {
                Text(vm.selectedCategory?.emoji ?? "✨").font(.system(size: 52))
                Text("One step closer.")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(CC.textSecondary)
            }
        }
    }
}
