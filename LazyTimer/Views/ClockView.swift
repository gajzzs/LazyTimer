import SwiftUI

struct ClockView: View {
    @ObservedObject var timerManager: TimerManager
    var isOverlay: Bool = false
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: isOverlay ? 24 : 16) {
            timeDisplay
            dateDisplay
            
            if !isOverlay {
                quickFocusSection
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var timeDisplay: some View {
        Text(formattedTime)
            .font(.system(size: isOverlay ? 160 : 72, weight: .ultraLight, design: .monospaced))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
    
    private var dateDisplay: some View {
        Text(formattedDate)
            .font(.system(size: isOverlay ? 24 : 18))
            .foregroundColor(.white.opacity(0.7))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: currentTime)
    }
    
    private var quickFocusSection: some View {
        VStack(spacing: 12) {
            Text("Quick Focus")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                ForEach([5, 15, 25], id: \.self) { minutes in
                    Button(action: {
                        timerManager.mode = .pomodoro
                        timerManager.pomodoroTime = minutes * 60
                        timerManager.currentSession = .work
                    }) {
                        Text("\(minutes)m")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.15))
        .cornerRadius(16)
    }
}
