import SwiftUI
import AppKit

@MainActor
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    
    @Published var activeMode: DisplayMode = .window
    
    enum DisplayMode {
        case window
        case overlay
        case floating
    }
    
    // Controllers
    let overlayController = OverlayWindowController()
    let floatingController = FloatingWindowController()
    
    private init() {}
    
    func switchTo(_ mode: DisplayMode, timerManager: TimerManager, gradient: GradientPreset) {
        // 1. Close current mode's specific windows (except main window which we just hide/show)
        switch activeMode {
        case .window:
            NSApp.windows.first(where: { $0.title == "LazyTimer" })?.orderOut(nil)
        case .overlay:
            overlayController.hideOverlay()
        case .floating:
            floatingController.hideFloatingWindow()
        }
        
        // 2. Activate new mode
        activeMode = mode
        
        switch mode {
        case .window:
            NSApp.activate(ignoringOtherApps: true)
            // Re-show main window
            if let window = NSApp.windows.first(where: { $0.title == "LazyTimer" || $0.isVisible == false }) {
                window.makeKeyAndOrderFront(nil)
            }
            
        case .overlay:
            overlayController.showOverlay(timerManager: timerManager, gradient: gradient)
            
        case .floating:
            floatingController.showFloatingWindow(timerManager: timerManager, gradient: gradient)
        }
    }
    
    func toggleSettings() {
        if activeMode == .window {
            // In window mode, maybe toggle a sheet or just rely on the existing button
            // But for menu bar access, we might want a global settings window
             SettingsWindowController.shared.showSettings()
        } else {
             SettingsWindowController.shared.showSettings()
        }
    }
}

class SettingsWindowController: NSObject {
    static let shared = SettingsWindowController()
    private var settingsWindow: NSWindow?
    
    func showSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.center()
        window.isReleasedWhenClosed = false
        
        // We need to inject dependencies properly here, 
        // but for now let's assume we can get them or pass them.
        // This is a bit tricky with the current architecture.
        // Let's refactor LazyTimerApp to pass these down or use a singleton for TimerManager if appropriate.
        // For now, I'll rely on the pure SwiftUI settings view invoked from the App struct, 
        // or we can make a dedicated WindowGroup for settings in the App.
    }
}
