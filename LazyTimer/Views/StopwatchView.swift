import SwiftUI

struct StopwatchView: View {
    @ObservedObject var timerManager: TimerManager
    var isOverlay: Bool = false
    
    var body: some View {
        VStack(spacing: isOverlay ? 40 : 24) {
            timerDisplay
            controlButtons
        }
    }
    
    private var timerDisplay: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: isOverlay ? 160 : 72, weight: .ultraLight, design: .monospaced))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var controlButtons: some View {
        HStack(spacing: isOverlay ? 32 : 16) {
            Button(action: { timerManager.toggleTimer() }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: isOverlay ? 32 : 24))
                    .frame(width: isOverlay ? 80 : 56, height: isOverlay ? 80 : 56)
                    .background(timerManager.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Button(action: { timerManager.reset() }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: isOverlay ? 32 : 24))
                    .frame(width: isOverlay ? 80 : 56, height: isOverlay ? 80 : 56)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}
