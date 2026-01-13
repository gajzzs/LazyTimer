import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject var timerManager: TimerManager
    let gradient: GradientPreset
    
    var body: some View {
        VStack(spacing: 12) {
            Text(timerManager.formattedTime)
                .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                Button(action: { timerManager.toggleTimer() }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                        .background(timerManager.isRunning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Button(action: { timerManager.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: gradient.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

class FloatingWindowController: NSObject {
    private var floatingWindow: NSPanel?
    
    func showFloatingWindow(timerManager: TimerManager, gradient: GradientPreset) {
        if floatingWindow != nil {
            hideFloatingWindow()
            return
        }
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 180, height: 120),
            styleMask: [.borderless, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        
        let floatingView = FloatingTimerView(timerManager: timerManager, gradient: gradient)
        panel.contentView = NSHostingView(rootView: floatingView)
        
        if let screen = NSScreen.main {
            let x = screen.frame.maxX - 200
            let y = screen.frame.maxY - 150
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        panel.orderFrontRegardless()
        floatingWindow = panel
    }
    
    func hideFloatingWindow() {
        floatingWindow?.close()
        floatingWindow = nil
    }
}
