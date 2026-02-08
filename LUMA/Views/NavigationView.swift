import SwiftUI

struct NavigationView: View {
    let destination: POI
    let onArrive: () -> Void
    @StateObject private var batteryManager = BatteryManager()
    @StateObject private var audioManager = AudioManager.shared
    @State private var eta = "12:47"
    @State private var showingJourneyMode = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Minimalist Route Line (Placeholder)
            Path { path in
                path.move(to: CGPoint(x: 200, y: 700))
                path.addLine(to: CGPoint(x: 200, y: 100))
            }
            .stroke(Color.white, lineWidth: 2)
            
            // User Location Dot
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .position(x: 200, y: 700)
            
            // UI Overlays
            VStack {
                // Top ETA
                Text(eta)
                    .font(.system(size: 24, weight: .light, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Spacer()
                
                // Bottom Battery
                Image(systemName: batteryManager.batteryIcon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
            }
            
            // Journey Mode Overlay
            if showingJourneyMode {
                JourneyModeView(onClose: { showingJourneyMode = false })
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring()) {
                            showingJourneyMode = true
                        }
                    }
                }
        )
        .onTapGesture {
            onArrive()
        }
    }
}

struct JourneyModeView: View {
    let onClose: () -> Void
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("AMBIENT")
                    .font(.system(size: 12, weight: .thin, design: .monospaced))
                    .foregroundColor(.gray)
                
                HStack(spacing: 30) {
                    ForEach(AudioManager.SoundType.allCases, id: \.self) { sound in
                        Button(action: {
                            audioManager.setSound(sound)
                            audioManager.play()
                        }) {
                            Text(sound.rawValue.uppercased())
                                .font(.system(size: 14, weight: audioManager.currentSound == sound ? .bold : .light, design: .monospaced))
                                .foregroundColor(audioManager.currentSound == sound ? .white : .gray)
                        }
                    }
                }
            }
            
            Button(action: {
                withAnimation {
                    onClose()
                }
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .padding()
            }
            
            Spacer().frame(height: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.95))
        .edgesIgnoringSafeArea(.all)
    }
}

class BatteryManager: ObservableObject {
    @Published var batteryLevel: Float = 0.0
    @Published var batteryIcon: String = "battery.100"
    
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBattery()
        NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { _ in
            self.updateBattery()
        }
    }
    
    private func updateBattery() {
        batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel < 0.2 {
            batteryIcon = "battery.0"
        } else if batteryLevel < 0.5 {
            batteryIcon = "battery.25"
        } else if batteryLevel < 0.8 {
            batteryIcon = "battery.75"
        } else {
            batteryIcon = "battery.100"
        }
    }
}
