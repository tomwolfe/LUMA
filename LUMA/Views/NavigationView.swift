import SwiftUI

struct NavigationView: View {
    let destination: POIItem
    let onArrive: () -> Void
    @StateObject private var batteryManager = BatteryManager()
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject private var mapManager = MapManager.shared
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var eta = "12:47"
    @State private var showingJourneyMode = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Real Mapbox Map with OSRM Route
            MapboxView()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8) // Keep the minimalist aesthetic
            
            // UI Overlays
            VStack {
                // Top ETA and Instruction
                VStack(spacing: 8) {
                    Text(eta)
                        .font(.system(size: 24, weight: .light, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if let firstInstruction = mapManager.instructions.first {
                        Text(firstInstruction.uppercased())
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
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
        .onAppear {
            mapManager.calculateRoute(to: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude), city: destination.city)
        }
        .onReceive(locationManager.$lastLocation) { location in
            guard let location = location else { return }
            let destLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
            let distance = location.distance(from: destLocation)
            
            if distance < 20 {
                onArrive()
            }
            
            // Also update route if user moved significantly (optional, but good for "production-ready")
            // For now, let's just stick to the proximity check as requested.
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
