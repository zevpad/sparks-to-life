import SwiftUI

// MARK: - Design Tokens

enum CC {
    // Backgrounds
    static let bg            = Color(hex: "#0A0A0A")
    static let card          = Color(hex: "#141414")
    static let cardElevated  = Color(hex: "#1E1E1E")
    static let border        = Color(white: 1, opacity: 0.08)

    // Brand
    static let green  = Color(hex: "#00E87A")
    static let orange = Color(hex: "#FF6B2B")
    static let purple = Color(hex: "#7C3AED")
    static let yellow = Color(hex: "#FFD60A")
    static let red    = Color(hex: "#FF3B30")

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color(white: 1, opacity: 0.55)
    static let textTertiary  = Color(white: 1, opacity: 0.3)

    // Spacing
    static let xs: CGFloat  = 4
    static let s: CGFloat   = 8
    static let m: CGFloat   = 16
    static let l: CGFloat   = 24
    static let xl: CGFloat  = 32
    static let xxl: CGFloat = 48

    // Radius
    static let rS: CGFloat  = 8
    static let rM: CGFloat  = 16
    static let rL: CGFloat  = 20
    static let rXL: CGFloat = 28

    // Animations
    static let snap   = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let smooth = Animation.spring(response: 0.35, dampingFraction: 0.7)

    // Intensity → color
    static func intensityColor(_ v: Int) -> Color {
        switch v {
        case 1...3:  return green
        case 4...5:  return yellow
        case 6...7:  return orange
        case 8...10: return red
        default:     return textSecondary
        }
    }
}

// MARK: - Hex Color

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var n: UInt64 = 0
        Scanner(string: h).scanHexInt64(&n)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255,(n>>8)*17,(n>>4&0xF)*17,(n&0xF)*17)
        case 6:  (a,r,g,b) = (255,n>>16,n>>8&0xFF,n&0xFF)
        case 8:  (a,r,g,b) = (n>>24,n>>16&0xFF,n>>8&0xFF,n&0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Glow

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.7), radius: radius * 0.5)
            .shadow(color: color.opacity(0.4), radius: radius)
            .shadow(color: color.opacity(0.2), radius: radius * 2)
    }
}

extension View {
    func glow(_ color: Color = CC.green, radius: CGFloat = 12) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Pulsing Border

struct PulsingBorderModifier: ViewModifier {
    @State private var pulsing = false
    let color: Color

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: CC.rL)
                .stroke(color.opacity(pulsing ? 0 : 0.5), lineWidth: 2)
                .scaleEffect(pulsing ? 1.08 : 1)
                .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: pulsing)
        )
        .onAppear { pulsing = true }
    }
}

extension View {
    func pulsingBorder(_ color: Color = CC.green) -> some View {
        modifier(PulsingBorderModifier(color: color))
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .black))
                .kerning(-0.5)
                .foregroundColor(isEnabled ? .black : CC.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEnabled ? color : CC.card)
                .cornerRadius(CC.rL)
                .overlay(
                    RoundedRectangle(cornerRadius: CC.rL)
                        .stroke(isEnabled ? Color.clear : CC.border, lineWidth: 1)
                )
        }
        .disabled(!isEnabled)
        .glow(color, radius: isEnabled ? 14 : 0)
    }
}

// MARK: - Ghost Button

struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CC.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(CC.card)
                .cornerRadius(CC.rM)
                .overlay(RoundedRectangle(cornerRadius: CC.rM).stroke(CC.border, lineWidth: 1))
        }
    }
}

// MARK: - Page Header

struct PageHeader: View {
    let title: String
    var subtitle: String? = nil

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CC.s) {
            Text(title)
                .font(.system(size: 34, weight: .black))
                .kerning(-1)
                .foregroundColor(CC.textPrimary)
            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CC.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: CC.xs) {
            Text(value)
                .font(.system(size: 26, weight: .black))
                .kerning(-0.5)
                .foregroundColor(color)
                .minimumScaleFactor(0.55)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .kerning(0.3)
                .foregroundColor(CC.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CC.m)
        .background(CC.card)
        .cornerRadius(CC.rM)
        .overlay(RoundedRectangle(cornerRadius: CC.rM).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Win Summary Card

struct WinSummaryCard: View {
    let session: CravingSession

    var body: some View {
        VStack(spacing: CC.m) {
            HStack(alignment: .top) {
                Text(session.categoryEmoji)
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.categoryName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(CC.textPrimary)
                    Text(session.actionName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CC.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(session.wasSuccessful ? "-\(session.drop)" : "—")
                        .font(.system(size: 32, weight: .black))
                        .kerning(-1)
                        .foregroundColor(session.wasSuccessful ? CC.green : CC.textTertiary)
                        .glow(CC.green, radius: session.wasSuccessful ? 8 : 0)
                    Text("drop")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(CC.textTertiary)
                }
            }

            Rectangle().fill(CC.border).frame(height: 1)

            HStack(spacing: CC.m) {
                miniStat("Before", "\(session.intensityBefore)", CC.intensityColor(session.intensityBefore))
                miniStat("After",  "\(session.intensityAfter)",  CC.intensityColor(session.intensityAfter))
                miniStat("Saved",  "\(session.minutesSaved)m",   CC.orange)
            }
        }
        .padding(CC.l)
        .background(CC.card)
        .cornerRadius(CC.rL)
        .overlay(RoundedRectangle(cornerRadius: CC.rL).stroke(CC.green.opacity(0.2), lineWidth: 1))
    }

    private func miniStat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(CC.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Intensity Picker

struct IntensityPicker: View {
    let selected: Int
    let onSelect: (Int) -> Void

    private let labels = ["","Barely there","Mild","Noticeable","Building","Moderate","Strong pull","Intense","Very intense","Overwhelming","Peak"]

    var body: some View {
        VStack(spacing: CC.m) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: CC.s), count: 5),
                spacing: CC.s
            ) {
                ForEach(1...10, id: \.self) { v in
                    let on = selected == v
                    let c  = CC.intensityColor(v)
                    Button { withAnimation(CC.snap) { onSelect(v) } } label: {
                        Text("\(v)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(on ? .black : c)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(on ? c : c.opacity(0.12))
                            .cornerRadius(CC.rM)
                            .overlay(RoundedRectangle(cornerRadius: CC.rM).stroke(c.opacity(on ? 0 : 0.3), lineWidth: 1))
                            .scaleEffect(on ? 1.06 : 1)
                    }
                    .glow(c, radius: on ? 12 : 0)
                }
            }
            if selected > 0 {
                Text(labels[selected])
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CC.intensityColor(selected))
                    .animation(CC.smooth, value: selected)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: CravingSession

    var body: some View {
        HStack(spacing: CC.m) {
            Text(session.categoryEmoji)
                .font(.system(size: 28))
                .frame(width: 46, height: 46)
                .background(CC.cardElevated)
                .cornerRadius(CC.s)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.categoryName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(CC.textPrimary)
                Text(session.actionName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CC.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(session.wasSuccessful ? "-\(session.drop)" : "—")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(session.wasSuccessful ? CC.green : CC.textTertiary)
                Text(relativeTime(session.date))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(CC.textTertiary)
            }
        }
        .padding(CC.m)
        .background(CC.card)
        .cornerRadius(CC.rM)
    }

    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Confetti

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let width: CGFloat
    let height: CGFloat
    var rotation: Double
    var opacity: Double = 1
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    private let palette: [Color] = [CC.green, CC.orange, CC.yellow, CC.purple, .white, CC.red]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.width, height: p.height)
                        .rotationEffect(.degrees(p.rotation))
                        .position(x: p.x, y: p.y)
                        .opacity(p.opacity)
                }
            }
            .onAppear { burst(in: geo.size) }
        }
        .allowsHitTesting(false)
    }

    private func burst(in size: CGSize) {
        let cx = size.width / 2
        particles = (0..<60).map { i in
            ConfettiParticle(
                color:    palette[i % palette.count],
                x:        cx + .random(in: -30...30),
                y:        -10,
                width:    .random(in: 6...14),
                height:   .random(in: 3...7),
                rotation: .random(in: 0...360)
            )
        }

        for i in particles.indices {
            let delay = Double(i) * 0.018
            withAnimation(.interpolatingSpring(stiffness: 40, damping: 8).delay(delay)) {
                particles[i].x        = .random(in: 20...(size.width - 20))
                particles[i].y        = .random(in: size.height * 0.05 ... size.height * 0.75)
                particles[i].rotation += .random(in: 200...540)
            }
            withAnimation(.easeIn(duration: 0.9).delay(delay + 1.1)) {
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - Streak Banner

struct StreakBanner: View {
    let streak: Int

    var body: some View {
        HStack(spacing: CC.m) {
            Text(emoji).font(.system(size: 26))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .black)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 13, weight: .medium)).foregroundColor(CC.purple.opacity(0.8))
            }
            Spacer()
        }
        .padding(CC.m)
        .background(CC.purple.opacity(0.12))
        .cornerRadius(CC.rM)
        .overlay(RoundedRectangle(cornerRadius: CC.rM).stroke(CC.purple.opacity(0.35), lineWidth: 1))
        .glow(CC.purple, radius: 8)
    }

    private var emoji: String {
        streak >= 30 ? "🔥" : streak >= 7 ? "⚡" : "✨"
    }
    private var title: String {
        streak >= 30 ? "\(streak)-day streak. Legend." :
        streak >= 7  ? "\(streak)-day streak. On fire." :
                       "\(streak)-day streak. Keep going."
    }
    private var subtitle: String {
        streak >= 30 ? "One month of showing up. Real." :
        streak >= 7  ? "A week straight. That's discipline." :
                       "Don't break it."
    }
}

// MARK: - Momentum Banner

struct MomentumBanner: View {
    let momentum: String
    let converted: Int

    var body: some View {
        HStack(spacing: CC.m) {
            Text(emoji).font(.system(size: 26))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .black)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 13, weight: .medium)).foregroundColor(CC.green.opacity(0.7))
            }
            Spacer()
        }
        .padding(CC.m)
        .background(CC.green.opacity(0.08))
        .cornerRadius(CC.rM)
        .overlay(RoundedRectangle(cornerRadius: CC.rM).stroke(CC.green.opacity(0.25), lineWidth: 1))
        .glow(CC.green, radius: 6)
    }

    private var emoji: String {
        switch momentum {
        case "STRONG": return "🔥"
        case "RISING": return "⚡"
        default:       return "✨"
        }
    }

    private var title: String {
        switch momentum {
        case "STRONG": return "Strong momentum. Keep building."
        case "RISING": return "Rising. You're in it."
        default:       return "Steady. One more today."
        }
    }

    private var subtitle: String {
        "\(converted) cravings converted. Every craving is energy."
    }
}
