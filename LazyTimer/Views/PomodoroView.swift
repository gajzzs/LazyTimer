import SwiftUI

struct PomodoroView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var showSettings: Bool
    var isOverlay: Bool = false
    
    @State private var isEditingTime = false
    @State private var isEditingLabel = false
    @State private var editMinutes: String = ""
    @State private var editSeconds: String = ""
    @State private var editLabel: String = ""
    
    var body: some View {
        VStack(spacing: isOverlay ? 40 : 24) {
            if !isOverlay || !timerManager.isRunning {
                sessionButtons
            }
            
            timerDisplay
            
            if !isOverlay || !timerManager.isRunning {
                sessionInfo
            }
            
            controlButtons
        }
        .sheet(isPresented: $isEditingTime) {
            timeEditSheet
        }
        .sheet(isPresented: $isEditingLabel) {
            labelEditSheet
        }
    }
    
    private var sessionButtons: some View {
        HStack(spacing: 12) {
            ForEach([SessionType.work, .shortBreak, .longBreak], id: \.self) { session in
                Button(action: { timerManager.switchSession(session) }) {
                    Text(session.rawValue)
                        .font(.system(size: isOverlay ? 16 : 14, weight: .medium))
                        .padding(.horizontal, isOverlay ? 20 : 16)
                        .padding(.vertical, isOverlay ? 12 : 8)
                        .background(
                            timerManager.currentSession == session
                                ? Color.blue.opacity(0.2)
                                : Color.white.opacity(0.1)
                        )
                        .foregroundColor(
                            timerManager.currentSession == session
                                ? .blue
                                : .white.opacity(0.8)
                        )
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var timerDisplay: some View {
        Button(action: {
            let totalSeconds = timerManager.pomodoroTime
            editMinutes = String(totalSeconds / 60)
            editSeconds = String(format: "%02d", totalSeconds % 60)
            isEditingTime = true
        }) {
            Text(timerManager.formattedTime)
                .font(.system(size: isOverlay ? 160 : 72, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(timerManager.isRunning)
        .opacity(timerManager.isRunning ? 1 : 0.95)
    }
    
    private var sessionInfo: some View {
        HStack(spacing: 0) {
            Text("Session \(timerManager.sessionCount + 1) • ")
                .font(.system(size: isOverlay ? 18 : 14))
                .foregroundColor(.white.opacity(0.7))
            
            Button(action: {
                editLabel = timerManager.sessionLabel
                isEditingLabel = true
            }) {
                Text(timerManager.sessionLabel)
                    .font(.system(size: isOverlay ? 18 : 14))
                    .foregroundColor(.white.opacity(0.9))
                    .underline(pattern: .dot, color: .white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: isOverlay ? 32 : 16) {
            Button(action: { timerManager.toggleTimer() }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: isOverlay ? 32 : 24))
                    .frame(width: isOverlay ? 80 : 56, height: isOverlay ? 80 : 56)
                    .background(timerManager.isRunning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Button(action: { timerManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: isOverlay ? 32 : 24))
                    .frame(width: isOverlay ? 80 : 56, height: isOverlay ? 80 : 56)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            if !isOverlay {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var timeEditSheet: some View {
        VStack(spacing: 20) {
            Text("Edit Timer")
                .font(.headline)
            
            HStack(spacing: 8) {
                VStack {
                    TextField("Min", text: $editMinutes)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(":")
                    .font(.title)
                
                VStack {
                    TextField("Sec", text: $editSeconds)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                    Text("Seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isEditingTime = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Set Time") {
                    let minutes = Int(editMinutes) ?? 0
                    let seconds = Int(editSeconds) ?? 0
                    timerManager.pomodoroTime = (minutes * 60) + seconds
                    isEditingTime = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 250)
    }
    
    private var labelEditSheet: some View {
        VStack(spacing: 20) {
            Text("Edit Session Label")
                .font(.headline)
            
            TextField("Label", text: $editLabel)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isEditingLabel = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    switch timerManager.currentSession {
                    case .work:
                        timerManager.customWorkLabel = editLabel
                    case .shortBreak:
                        timerManager.customShortBreakLabel = editLabel
                    case .longBreak:
                        timerManager.customLongBreakLabel = editLabel
                    }
                    isEditingLabel = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 280)
    }
}
