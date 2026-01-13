import SwiftUI

struct GradientBackground: View {
    var colors: [Color]
    var angle: Double
    var opacity: Double
    
    init(
        colors: [Color] = [Color(hex: "#b22222"), Color(hex: "#c54b8c")],
        angle: Double = 135,
        opacity: Double = 1.0
    ) {
        self.colors = colors
        self.angle = angle
        self.opacity = opacity
    }
    
    var body: some View {
        Group {
            if colors.count == 1 {
                colors[0]
            } else {
                LinearGradient(
                    colors: colors,
                    startPoint: gradientStart,
                    endPoint: gradientEnd
                )
            }
        }
        .opacity(opacity)
        .ignoresSafeArea()
    }
    
    private var gradientStart: UnitPoint {
        let radians = angle * .pi / 180
        return UnitPoint(
            x: 0.5 - cos(radians) * 0.5,
            y: 0.5 - sin(radians) * 0.5
        )
    }
    
    private var gradientEnd: UnitPoint {
        let radians = angle * .pi / 180
        return UnitPoint(
            x: 0.5 + cos(radians) * 0.5,
            y: 0.5 + sin(radians) * 0.5
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GradientPreset: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let colors: [Color]
    let angle: Double
    let type: String
    
    static func == (lhs: GradientPreset, rhs: GradientPreset) -> Bool {
        return lhs.name == rhs.name
    }
}

let gradientPresets: [GradientPreset] = [
    // Special Types
    GradientPreset(name: "None (Transparent)", colors: [Color.clear], angle: 0, type: "none"),
    GradientPreset(name: "Custom Image", colors: [Color.clear], angle: 0, type: "image"),
    
    // Original Datezo Gradients - Converted to Mesh (9 colors for 3x3 grid)
    GradientPreset(name: "Love, Harmony & Peace", colors: [
        Color(hex: "#ffff00"), Color(hex: "#e6a64a"), Color(hex: "#c54b8c"),
        Color(hex: "#e6a64a"), Color(hex: "#c54b8c"), Color(hex: "#d47a6e"),
        Color(hex: "#c54b8c"), Color(hex: "#d47a6e"), Color(hex: "#c54b8c")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Harmony & Creative", colors: [
        Color(hex: "#f5deb3"), Color(hex: "#faef5a"), Color(hex: "#ffff00"),
        Color(hex: "#faef5a"), Color(hex: "#e6a64a"), Color(hex: "#c54b8c"),
        Color(hex: "#ffff00"), Color(hex: "#c54b8c"), Color(hex: "#c54b8c")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Focus & Achievements", colors: [
        Color(hex: "#00ffff"), Color(hex: "#00bfff"), Color(hex: "#007fff"),
        Color(hex: "#00bfff"), Color(hex: "#7654a7"), Color(hex: "#eb284f"),
        Color(hex: "#007fff"), Color(hex: "#eb284f"), Color(hex: "#eb284f")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Focus, Achievements & Creative", colors: [
        Color(hex: "#f5deb3"), Color(hex: "#7aefe1"), Color(hex: "#00ffff"),
        Color(hex: "#7aefe1"), Color(hex: "#007fff"), Color(hex: "#7654a7"),
        Color(hex: "#00ffff"), Color(hex: "#007fff"), Color(hex: "#eb284f")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Freedom & Deep Thinking", colors: [
        Color(hex: "#ccccff"), Color(hex: "#d08cc6"), Color(hex: "#c54b8c"),
        Color(hex: "#d08cc6"), Color(hex: "#d8396e"), Color(hex: "#eb284f"),
        Color(hex: "#c54b8c"), Color(hex: "#eb284f"), Color(hex: "#eb284f")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Freedom, Thinking & Creative", colors: [
        Color(hex: "#f5deb3"), Color(hex: "#e0d5d9"), Color(hex: "#ccccff"),
        Color(hex: "#e0d5d9"), Color(hex: "#c54b8c"), Color(hex: "#d8396e"),
        Color(hex: "#ccccff"), Color(hex: "#c54b8c"), Color(hex: "#eb284f")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Degrade Negative Thoughts", colors: [
        Color(hex: "#b22222"), Color(hex: "#c17791"), Color(hex: "#ccccff"),
        Color(hex: "#c17791"), Color(hex: "#c54b8c"), Color(hex: "#e2a647"),
        Color(hex: "#ccccff"), Color(hex: "#c54b8c"), Color(hex: "#ffff00")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Cosmic Dream", colors: [
        Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460"),
        Color(hex: "#533483"), Color(hex: "#e94560"), Color(hex: "#0f3460"),
        Color(hex: "#1a1a2e"), Color(hex: "#533483"), Color(hex: "#16213e")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Ocean Depth", colors: [
        Color(hex: "#0077b6"), Color(hex: "#00b4d8"), Color(hex: "#023e8a"),
        Color(hex: "#0096c7"), Color(hex: "#48cae4"), Color(hex: "#0077b6"),
        Color(hex: "#023e8a"), Color(hex: "#00b4d8"), Color(hex: "#90e0ef")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Sunset Glow", colors: [
        Color(hex: "#ff6b6b"), Color(hex: "#ffd93d"), Color(hex: "#ff8c42"),
        Color(hex: "#ff6b6b"), Color(hex: "#ffd93d"), Color(hex: "#ff8c42"),
        Color(hex: "#c44569"), Color(hex: "#f8b500"), Color(hex: "#ff6348")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Blossom", colors: [
        Color(hex: "#ff9a9e"), Color(hex: "#fecfef"), Color(hex: "#fad0c4"),
        Color(hex: "#fbc2eb"), Color(hex: "#a18cd1"), Color(hex: "#fad0c4"),
        Color(hex: "#ff9a9e"), Color(hex: "#fecfef"), Color(hex: "#fbc2eb")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Northern Lights", colors: [
        Color(hex: "#0f0c29"), Color(hex: "#302b63"), Color(hex: "#24243e"),
        Color(hex: "#00d9ff"), Color(hex: "#00ff87"), Color(hex: "#302b63"),
        Color(hex: "#0f0c29"), Color(hex: "#24243e"), Color(hex: "#00d9ff")
    ], angle: 0, type: "mesh"),
    
    GradientPreset(name: "Ember", colors: [
        Color(hex: "#f12711"), Color(hex: "#f5af19"), Color(hex: "#c33764"),
        Color(hex: "#f12711"), Color(hex: "#ff6b35"), Color(hex: "#f5af19"),
        Color(hex: "#c33764"), Color(hex: "#f12711"), Color(hex: "#f5af19")
    ], angle: 0, type: "mesh")
]
