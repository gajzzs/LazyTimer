import SwiftUI
import AppKit

class OverlayWindowController: NSObject, ObservableObject {
    private var overlayWindow: NSPanel?
    private var completionWindow: NSPanel?
    @Published var isOverlayVisible = false
    
    func showOverlay(timerManager: TimerManager, gradient: GradientPreset) {
        if overlayWindow != nil {
            hideOverlay()
            return
        }
        
        guard let screen = NSScreen.main else { return }
        
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        
        let overlayView = OverlayContentView(
            timerManager: timerManager,
            gradient: gradient,
            onClose: { [weak self] in
                self?.hideOverlay()
            }
        )
        
        panel.contentView = NSHostingView(rootView: overlayView)
        panel.orderFrontRegardless()
        
        overlayWindow = panel
        isOverlayVisible = true
    }
    
    func hideOverlay() {
        overlayWindow?.close()
        overlayWindow = nil
        isOverlayVisible = false
    }
    
    func showCompletionOverlay(message: String, gradient: GradientPreset) {
        guard let screen = NSScreen.main else { return }
        
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.hidesOnDeactivate = false
        
        let completionView = CompletionOverlayView(
            message: message,
            gradient: gradient,
            onDismiss: { [weak self] in
                self?.hideCompletionOverlay()
            }
        )
        
        panel.contentView = NSHostingView(rootView: completionView)
        panel.orderFrontRegardless()
        
        completionWindow = panel
    }
    
    func hideCompletionOverlay() {
        completionWindow?.close()
        completionWindow = nil
    }
}

struct OverlayContentView: View {
    @ObservedObject var timerManager: TimerManager
    let gradient: GradientPreset
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            gradientBackground
            
            positionedTimer
            
            if timerManager.isShowingCompletionMessage {
                completionMessageOverlay
            }
        }
        .opacity(timerManager.overlayOpacity)
    }
    
    @ViewBuilder
    private var gradientBackground: some View {
        switch gradient.type {
        case "none":
            Color.clear
                .ignoresSafeArea()
            
        case "image":
            if !timerManager.customImagePath.isEmpty,
               let nsImage = NSImage(contentsOfFile: timerManager.customImagePath) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Color.black.opacity(0.3)
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
    
    @ViewBuilder
    private var completionMessageOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("⏰")
                    .font(.system(size: 80))
                
                Text(timerManager.completionMessageText)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                
                Text("Click anywhere or wait to dismiss")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    @ViewBuilder
    private var positionedTimer: some View {
        switch timerManager.overlayPosition {
        case .center:
            VStack {
                Spacer()
                timerContent
                Spacer()
                hintText
            }
            
        case .topLeft:
            VStack {
                HStack {
                    timerContent
                    Spacer()
                }
                .padding(60)
                Spacer()
                hintText
            }
            
        case .topRight:
            VStack {
                HStack {
                    Spacer()
                    timerContent
                }
                .padding(60)
                Spacer()
                hintText
            }
            
        case .bottomLeft:
            VStack {
                Spacer()
                HStack {
                    timerContent
                    Spacer()
                }
                .padding(60)
                hintText
            }
            
        case .bottomRight:
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    timerContent
                }
                .padding(60)
                hintText
            }
        }
    }
    
    private var timerContent: some View {
        VStack(spacing: timerManager.overlayPosition == .center ? 40 : 16) {
            Text(timerManager.formattedTime)
                .font(.system(size: timerManager.overlayPosition == .center ? 200 : 80, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            if timerManager.mode == .pomodoro {
                Text("Session \(timerManager.sessionCount + 1) • \(timerManager.sessionLabel)")
                    .font(timerManager.overlayPosition == .center ? .title2 : .caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if !timerManager.subtitleText.isEmpty {
                subtitleView
            }
        }
    }
    
    private var subtitleView: some View {
        Text(timerManager.subtitleText)
            .font(subtitleFont)
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
    }
    
    private var subtitleFont: Font {
        let size = timerManager.subtitleFontSize
        var font: Font
        
        if timerManager.subtitleFontName == "System" {
            font = .system(size: size)
        } else {
            font = .custom(timerManager.subtitleFontName, size: size)
        }
        
        if timerManager.subtitleBold {
            font = font.bold()
        }
        if timerManager.subtitleItalic {
            font = font.italic()
        }
        
        return font
    }
    
    private var hintText: some View {
        Text("Menu bar to control • ⌘⇧O to close")
            .font(.caption)
            .foregroundColor(.white.opacity(0.4))
            .padding(.bottom, 20)
    }
}

struct CompletionOverlayView: View {
    let message: String
    let gradient: GradientPreset
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if gradient.type == "solid" {
                gradient.colors[0]
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: gradient.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("⏰")
                    .font(.system(size: 120))
                
                Text(message)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 80)
                
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.title2)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}
