import SwiftUI
import Combine
import AVFoundation

enum TimerMode: String, CaseIterable {
    case pomodoro = "Pomodoro"
    case stopwatch = "Stopwatch"
    case clock = "Clock"
}

enum SessionType: String {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

enum TimerPosition: String, CaseIterable {
    case center = "Center"
    case topLeft = "Top Left"
    case topRight = "Top Right"
    case bottomLeft = "Bottom Left"
    case bottomRight = "Bottom Right"
}

enum CompletionAction: String, CaseIterable {
    case beep = "System Beep"
    case speakText = "Speak Text"
    case showMessage = "Show Message Overlay"
    case playSound = "Play Sound File"
}

@MainActor
class TimerManager: ObservableObject {
    @Published var mode: TimerMode = .pomodoro
    @Published var currentSession: SessionType = .work
    @Published var sessionCount: Int = 0
    
    @Published var pomodoroTime: Int = 25 * 60
    @Published var stopwatchTime: Int = 0
    @Published var isRunning: Bool = false
    
    @Published var workDuration: Int = 25
    @Published var shortBreakDuration: Int = 5
    @Published var longBreakDuration: Int = 15
    
    @Published var overlayOpacity: Double = 0.85
    @Published var overlayPosition: TimerPosition = .center
    
    @Published var subtitleText: String = ""
    @Published var subtitleFontSize: Double = 24
    @Published var subtitleBold: Bool = false
    @Published var subtitleItalic: Bool = false
    @Published var subtitleFontName: String = "System"
    
    @Published var customWorkLabel: String = "🎯 Focus Time"
    @Published var customShortBreakLabel: String = "☕ Short Break"
    @Published var customLongBreakLabel: String = "🌴 Long Break"
    
    @Published var completionAction: CompletionAction = .beep
    @Published var completionText: String = "Time is up! Take a break."
    @Published var completionSoundPath: String = ""
    
    @Published var isShowingCompletionMessage: Bool = false
    @Published var completionMessageText: String = ""
    
    @Published var customImagePath: String = ""
    @Published var selectedGradientIndex: Int = 10
    
    var selectedGradient: GradientPreset {
        guard selectedGradientIndex >= 0 && selectedGradientIndex < gradientPresets.count else {
            return gradientPresets[10]
        }
        return gradientPresets[selectedGradientIndex]
    }
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    var formattedTime: String {
        let seconds: Int
        switch mode {
        case .pomodoro:
            seconds = pomodoroTime
        case .stopwatch:
            seconds = stopwatchTime
        case .clock:
            return formatClock()
        }
        return formatSeconds(seconds)
    }
    
    var sessionLabel: String {
        switch currentSession {
        case .work: return customWorkLabel
        case .shortBreak: return customShortBreakLabel
        case .longBreak: return customLongBreakLabel
        }
    }
    
    func formatSeconds(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatClock() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    func toggleTimer() {
        isRunning.toggle()
        if isRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func tick() {
        switch mode {
        case .pomodoro:
            if pomodoroTime > 0 {
                pomodoroTime -= 1
            } else {
                handleSessionComplete()
            }
        case .stopwatch:
            stopwatchTime += 1
        case .clock:
            break
        }
    }
    
    func handleSessionComplete() {
        isRunning = false
        stopTimer()
        
        executeCompletionAction()
        
        if currentSession == .work {
            sessionCount += 1
            if sessionCount % 4 == 0 {
                switchSession(.longBreak)
            } else {
                switchSession(.shortBreak)
            }
        } else {
            switchSession(.work)
        }
    }
    
    func executeCompletionAction() {
        switch completionAction {
        case .beep:
            NSSound.beep()
            
        case .speakText:
            speakText(completionText)
            
        case .showMessage:
            showCompletionMessage(completionText)
            
        case .playSound:
            playCustomSound()
        }
    }
    
    func speakText(_ text: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        process.arguments = [text]
        try? process.run()
    }
    
    func showCompletionMessage(_ message: String) {
        completionMessageText = message
        isShowingCompletionMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.isShowingCompletionMessage = false
        }
    }
    
    func playCustomSound() {
        guard !completionSoundPath.isEmpty else {
            NSSound.beep()
            return
        }
        
        let url = URL(fileURLWithPath: completionSoundPath)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            NSSound.beep()
        }
    }
    
    func switchSession(_ session: SessionType) {
        currentSession = session
        switch session {
        case .work:
            pomodoroTime = workDuration * 60
        case .shortBreak:
            pomodoroTime = shortBreakDuration * 60
        case .longBreak:
            pomodoroTime = longBreakDuration * 60
        }
    }
    
    func reset() {
        isRunning = false
        stopTimer()
        isShowingCompletionMessage = false
        
        switch mode {
        case .pomodoro:
            switchSession(currentSession)
        case .stopwatch:
            stopwatchTime = 0
        case .clock:
            break
        }
    }
    
    func dismissCompletionMessage() {
        isShowingCompletionMessage = false
    }
}
