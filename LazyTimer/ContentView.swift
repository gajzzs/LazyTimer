import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var currentTime = Date()
    let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                header
                tabNavigation
                Spacer()
                timerContent
                Spacer()
            }
            .padding(32)
        }
        .frame(minWidth: 480, minHeight: 560)
        .onReceive(clockTimer) { _ in
            currentTime = Date()
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        let gradient = timerManager.selectedGradient
        
        switch gradient.type {
        case "none":
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
        case "image":
            if !timerManager.customImagePath.isEmpty,
               let nsImage = NSImage(contentsOfFile: timerManager.customImagePath) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()
            }
            
        case "mesh":
            if #available(macOS 15.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: Array(gradient.colors.prefix(9))
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(colors: gradient.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            
        default:
            LinearGradient(
                colors: gradient.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("LazyTimer")
                    .font(.custom("Avenir Next", size: 28).weight(.ultraLight))
                    .tracking(2)
                    .foregroundColor(.white)
                
                Text(formattedHeaderTime)
                    .font(.custom("SF Mono", size: 13).weight(.light))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                SettingsLink {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var tabNavigation: some View {
        HStack(spacing: 4) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                Button(action: { timerManager.mode = mode }) {
                    HStack(spacing: 8) {
                        Image(systemName: iconForMode(mode))
                        Text(mode.rawValue)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        timerManager.mode == mode
                            ? Color.white.opacity(0.3)
                            : Color.clear
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func iconForMode(_ mode: TimerMode) -> String {
        switch mode {
        case .pomodoro: return "timer"
        case .stopwatch: return "stopwatch"
        case .clock: return "clock"
        }
    }
    
    @ViewBuilder
    private var timerContent: some View {
        switch timerManager.mode {
        case .pomodoro:
            PomodoroView(timerManager: timerManager, showSettings: .constant(false))
        case .stopwatch:
            StopwatchView(timerManager: timerManager)
        case .clock:
            ClockView(timerManager: timerManager)
        }
    }
    
    private var formattedHeaderTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
}
