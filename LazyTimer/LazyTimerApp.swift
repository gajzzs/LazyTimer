import SwiftUI
import AppKit

@main
struct LazyTimerApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var windowManager = WindowManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 444, height: 666)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Show Overlay") {
                    windowManager.switchTo(.overlay, timerManager: timerManager, gradient: timerManager.selectedGradient)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Button("Show Floating Timer") {
                    windowManager.switchTo(.floating, timerManager: timerManager, gradient: timerManager.selectedGradient)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Button("Show Standard Window") {
                    windowManager.switchTo(.window, timerManager: timerManager, gradient: timerManager.selectedGradient)
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
        }
        
        MenuBarExtra {
            MenuBarView(
                timerManager: timerManager,
                windowManager: windowManager
            )
        } label: {
            Label {
                Text(timerManager.isRunning ? timerManager.formattedTime : "Timer")
            } icon: {
                Image(systemName: timerManager.isRunning ? "timer" : "timer.circle")
            }
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsWindowView(timerManager: timerManager)
        }
    }
}
