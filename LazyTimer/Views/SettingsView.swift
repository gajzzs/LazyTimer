import SwiftUI

struct SettingsWindowView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        TabView {
            appearanceTab
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            completionTab
                .tabItem {
                    Label("Completion", systemImage: "bell")
                }
        }
        .frame(width: 500, height: 550)
        .padding()
    }
    
    private var timerSettingsTab: some View {
        Form {
            Section("Pomodoro Durations (minutes)") {
                Stepper(value: $timerManager.workDuration, in: 1...60) {
                    HStack {
                        Text("Work")
                        Spacer()
                        Text("\(timerManager.workDuration) min")
                    }
                }
                
                Stepper(value: $timerManager.shortBreakDuration, in: 1...30) {
                    HStack {
                        Text("Short Break")
                        Spacer()
                        Text("\(timerManager.shortBreakDuration) min")
                    }
                }
                
                Stepper(value: $timerManager.longBreakDuration, in: 1...60) {
                    HStack {
                        Text("Long Break")
                        Spacer()
                        Text("\(timerManager.longBreakDuration) min")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private var appearanceTab: some View {
        Form {
            Section("Overlay") {
                VStack(alignment: .leading) {
                    Text("Opacity: \(Int(timerManager.overlayOpacity * 100))%")
                    Slider(value: $timerManager.overlayOpacity, in: 0.1...1.0, step: 0.05)
                }
                
                Picker("Timer Position", selection: $timerManager.overlayPosition) {
                    ForEach(TimerPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section("Subtitle Text (Under Timer)") {
                TextField("Enter text to show under timer...", text: $timerManager.subtitleText)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Text("Font Size: \(Int(timerManager.subtitleFontSize))pt")
                    Slider(value: $timerManager.subtitleFontSize, in: 12...72, step: 2)
                }
                
                Picker("Font", selection: $timerManager.subtitleFontName) {
                    Text("System").tag("System")
                    Text("SF Pro").tag("SF Pro")
                    Text("Helvetica Neue").tag("Helvetica Neue")
                    Text("Avenir").tag("Avenir")
                    Text("Georgia").tag("Georgia")
                    Text("Menlo").tag("Menlo")
                    Text("Courier").tag("Courier")
                }
                .pickerStyle(.menu)
                
                HStack(spacing: 16) {
                    Toggle("Bold", isOn: $timerManager.subtitleBold)
                    Toggle("Italic", isOn: $timerManager.subtitleItalic)
                }
                
                if !timerManager.subtitleText.isEmpty {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timerManager.subtitleText)
                        .font(previewFont)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Section("Background Preset") {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(Array(gradientPresets.enumerated()), id: \.offset) { index, preset in
                            PresetButton(preset: preset, isSelected: timerManager.selectedGradientIndex == index) {
                                timerManager.selectedGradientIndex = index
                                if preset.type == "image" {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        selectImageFile()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 180)
            }
            
            if timerManager.selectedGradient.type == "image" {
                Section("Custom Image") {
                    HStack {
                        if !timerManager.customImagePath.isEmpty {
                            Text(URL(fileURLWithPath: timerManager.customImagePath).lastPathComponent)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        } else {
                            Text("No image selected")
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Browse") {
                            selectImageFile()
                        }
                    }
                    
                    if !timerManager.customImagePath.isEmpty,
                       let nsImage = NSImage(contentsOfFile: timerManager.customImagePath) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private var completionTab: some View {
        Form {
            Section("When Timer Completes") {
                Picker("Action", selection: $timerManager.completionAction) {
                    ForEach(CompletionAction.allCases, id: \.self) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if timerManager.completionAction == .speakText || timerManager.completionAction == .showMessage {
                Section("Message Text") {
                    TextField("Enter message...", text: $timerManager.completionText)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("This text will be spoken or displayed when timer completes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if timerManager.completionAction == .playSound {
                Section("Sound File") {
                    HStack {
                        TextField("Sound file path...", text: $timerManager.completionSoundPath)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Browse") {
                            selectSoundFile()
                        }
                    }
                    
                    Text("Select an audio file (mp3, wav, m4a)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Test") {
                Button("Test Completion Action") {
                    timerManager.executeCompletionAction()
                }
                
                Text("Beep: plays system sound • Speak: uses text-to-speech • Show Message: displays overlay (needs main window) • Play Sound: plays selected file")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
    
    private func selectSoundFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio, .mp3, .wav]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            timerManager.completionSoundPath = panel.url?.path ?? ""
        }
    }
    
    private func selectImageFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            timerManager.customImagePath = panel.url?.path ?? ""
        }
    }
    
    private var previewFont: Font {
        let size = min(timerManager.subtitleFontSize, 24)
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
}

struct PresetButton: View {
    let preset: GradientPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    presetPreview
                }
                .frame(height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.black.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                )
                
                Text(preset.name)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var presetPreview: some View {
        switch preset.type {
        case "none":
            Color.gray.opacity(0.1)
                .overlay(
                    Image(systemName: "nosign")
                        .foregroundColor(.gray)
                )
            
        case "image":
            Color.gray.opacity(0.1)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
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
                    colors: Array(preset.colors.prefix(9))
                )
            } else {
                LinearGradient(colors: preset.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            
        default:
            LinearGradient(
                colors: preset.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
