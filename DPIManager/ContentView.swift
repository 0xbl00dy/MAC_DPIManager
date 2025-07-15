//Code of ContenView.swift

import SwiftUI


struct ContentView: View {
    @StateObject private var displayManager = DisplayManager()
    @State private var selectedDisplay: Display?
    @State private var action: String = "enable"
    @State private var resolution: String = "1920x1080"
    @State private var icon: String = "Default"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var customResolution: String = ""
    @State private var fontSmoothing: Int = 0
    @State private var showFontSmoothingInfo = false


    
    private let resolutions = [
        "1920x1080",
        "1920x1080 (fix underscaled)",
        "1920x1200",
        "2560x1440",
        "3000x2000",
        "3440x1440",
        "Custom"
    ]
    
    private let icons = [
        "Default",
        "iMac",
        "MacBook",
        "MacBook Pro",
        "LG Display",
        "Pro Display XDR"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack {
                Image(systemName: "display.2")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("HiDPI Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enhance display resolution on non-Retina displays")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            
            // Display Selection
            GroupBox(label: Text("DISPLAY SELECTION")) {
                if displayManager.isLoading {
                    ProgressView("Detecting displays...")
                        .frame(maxWidth: .infinity)
                } else if displayManager.displays.isEmpty {
                    Text("No displays detected")
                        .foregroundColor(.secondary)
                } else {
                    Picker("", selection: $selectedDisplay) {
                        ForEach(displayManager.displays) { display in
                            Text(display.description).tag(display as Display?)
                        }
                    }
                    .onAppear {
                        selectedDisplay = displayManager.displays.first
                    }
                }
                
                Button(action: {
                    displayManager.fetchDisplays()
                }) {
                    Label("Refresh Displays", systemImage: "arrow.clockwise")
                }
                .padding(.top, 5)
            }
            
            // Action Selection
            GroupBox(label: Text("ACTION")) {
                Picker("", selection: $action) {
                    Text("Enable HiDPI").tag("enable")
                    Text("Disable HiDPI").tag("disable")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if action == "enable" {
                    VStack(alignment: .leading, spacing: 15) {
                        // Resolution Options
                        VStack(alignment: .leading) {
                            Text("Resolution:")
                            Picker("", selection: $resolution) {
                                ForEach(resolutions, id: \.self) { res in
                                    Text(res)
                                }
                            }
                            .onChange(of: resolution) { oldValue, newValue in
                                if newValue != "Custom" {
                                    customResolution = ""
                                }
                            }

                            if resolution == "Custom" {
                                TextField("Enter resolution (e.g., 1856x1044)", text: $customResolution)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("Recommended: 1856x1044, 1600×900, 2048×1152, 2560×1440, 2880×1620, 3200×1800")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                        }

                        // Font Smoothing Options
                        GroupBox(label:
                            HStack {
                                Text("FONT SMOOTHING (Optional)")
                                Spacer()
                                Button(action: {
                                    showFontSmoothingInfo = true
                                }) {
                                    Image(systemName: "questionmark.circle")
                                }
                                .buttonStyle(.plain)
                                .help("What is Font Smoothing?")
                            }
                        ) {
                            VStack(alignment: .leading, spacing: 15) {
                                Picker("", selection: $fontSmoothing) {
                                    ForEach([-1, 0, 1, 2, 3], id: \.self) { value in
                                        Text("\(value)").tag(value)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())

                                VStack {
                                    HStack {
                                        Button("Apply") {
                                            isProcessing = true
                                            displayManager.applyFontSmoothing(value: fontSmoothing) { success, message in
                                                isProcessing = false
                                                alertMessage = message
                                                showAlert = true
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)

                                        Button("Check") {
                                            displayManager.checkFontSmoothing { currentValue in
                                                alertMessage = "Current AppleFontSmoothing value: \(currentValue)"
                                                showAlert = true
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .alert("Font Smoothing Info", isPresented: $showFontSmoothingInfo) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("""
                        Font Smoothing controls how macOS renders text on screen:
                        (-1): Use system default
                        0: Disable font smoothing
                        1: Light font smoothing
                        2: Medium font smoothing
                        3: Strong font smoothing

                        Adjust depending on your display type or personal preference.
                        """)
                        }
                        .padding(.top, 10)
                        
                        // Icon Options
                        VStack(alignment: .leading) {
                            Text("Display Icon:")
                            Picker("", selection: $icon) {
                                ForEach(icons, id: \.self) { icon in
                                    Text(icon)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
            
            // Status Message
            Text(displayManager.message)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Apply Button
            Button(action: applySettings) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(5)
                } else {
                    Text(action == "enable" ? "Enable HiDPI" : "Disable HiDPI")
                        .font(.headline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedDisplay == nil || isProcessing)
            .padding(.bottom, 20)
        }
        .padding()
        .frame(width: 500)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Operation Complete"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func applySettings() {
        guard let display = selectedDisplay else { return }
        
        let finalResolution = resolution == "Custom" ? customResolution : resolution
        
        isProcessing = true
        displayManager.applySettings(
            display: display,
            action: action,
            resolution: finalResolution,  // Pass the custom resolution here
            icon: icon
        ) { success, message in
            isProcessing = false
            alertMessage = message
            showAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
