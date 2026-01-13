import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var windowManager: WindowManager
    
    var body: some View {
        VStack(spacing: 16) {
            header
            
            Divider()
            
            timerDisplay
            
            controls
            
            Divider()
            
            modeSelector
            
            Divider()
            
            displayOptions
            
            Divider()
            
            Button("Quit LazyTimer") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
        }
        .padding(16)
        .frame(width: 260)
    }
    
    private var header: some View {
        HStack {
            Text("LazyTimer")
                .font(.headline)
            Spacer()
            Text(timerManager.mode.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var timerDisplay: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 36, weight: .ultraLight, design: .monospaced))
            .frame(maxWidth: .infinity)
    }
    
    private var controls: some View {
        HStack(spacing: 12) {
            Button(action: { timerManager.toggleTimer() }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .frame(width: 40, height: 40)
                    .background(timerManager.isRunning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Button(action: { timerManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .frame(width: 40, height: 40)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timer Mode")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("", selection: $timerManager.mode) {
                ForEach(TimerMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var displayOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Mode")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { windowManager.switchTo(.window, timerManager: timerManager, gradient: timerManager.selectedGradient) }) {
                HStack {
                    Image(systemName: "macwindow")
                    Text("Standard Window")
                    if windowManager.activeMode == .window { Spacer(); Image(systemName: "checkmark") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            Button(action: { windowManager.switchTo(.floating, timerManager: timerManager, gradient: timerManager.selectedGradient) }) {
                HStack {
                    Image(systemName: "pip")
                    Text("Floating Timer")
                    if windowManager.activeMode == .floating { Spacer(); Image(systemName: "checkmark") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            Button(action: { windowManager.switchTo(.overlay, timerManager: timerManager, gradient: timerManager.selectedGradient) }) {
                HStack {
                    Image(systemName: "rectangle.inset.filled")
                    Text("Full Overlay")
                    if windowManager.activeMode == .overlay { Spacer(); Image(systemName: "checkmark") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }
}
