/*
 * STEP-BY-STEP GUIDE FOR NEW DEVELOPERS:
 * 1. Clone the repository: git clone <repo-url>
 * 2. Navigate to the project root: cd LUMA
 * 3. Run the setup script: ./setup.sh
 *    (This builds the OSRM C++ engine and generates OSRM.xcframework in OSRM-iOS/)
 * 4. Open the project in Xcode: open Package.swift
 * 5. Configure Mapbox Token:
 *    - Open LUMA/Info.plist
 *    - Add your Mapbox Public Access Token under the key 'MBXAccessToken'
 * 6. Build and Run:
 *    - Select the LUMA target and an iOS Simulator (ARM64).
 *    - Press Cmd+R.
 * 7. Verification:
 *    - The app should start on the home screen with a pulsing compass.
 *    - Tap the compass to open Search.
 *    - Search for 'Golden Gate', 'Eiffel', or 'Tokyo' to see POI results.
 *    - Select a result to start navigation and see the map.
 */

import SwiftUI

@main
struct LUMAApp: App {
    init() {
        MapManager.shared.configureOfflineMaps()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
