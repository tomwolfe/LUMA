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
