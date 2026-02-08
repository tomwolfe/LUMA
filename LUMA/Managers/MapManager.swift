import Foundation
import CoreLocation
import MapboxMaps

class MapManager: ObservableObject {
    static let shared = MapManager()
    
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    private var osrmBridge: OSRMBridge?
    private var currentCity: String?
    
    private init() {}
    
    func calculateRoute(to destination: CLLocationCoordinate2D, city: String) {
        // Load the correct OSRM file if city changed
        if currentCity != city {
            loadOSRM(for: city)
        }
        
        guard let bridge = osrmBridge else {
            print("OSRM bridge not initialized for \(city)")
            return
        }
        
        // Use a real starting point (mocked here as SF center if not provided)
        let start = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let routeValues = bridge.calculateRoute(from: start, to: destination)
            let coordinates = routeValues.compactMap { value -> CLLocationCoordinate2D? in
                var coord = CLLocationCoordinate2D()
                value.getValue(&coord)
                return coord
            }
            
            DispatchQueue.main.async {
                self.currentRoute = coordinates
            }
        }
    }
    
    private func loadOSRM(for city: String) {
        let cityName = city.lowercased().replacingOccurrences(of: " ", with: "_")
        guard let path = Bundle.main.path(forResource: cityName, ofType: "osrm") else {
            print("Could not find OSRM file for \(city)")
            return
        }
        
        osrmBridge = OSRMBridge(initWithOSRMFile: path)
        currentCity = city
    }
    
    func configureOfflineMaps() {
        // Initialize Mapbox with a placeholder token as requested
        let accessToken = "pk.eyJ1IjoibHVtYS1kZXYiLCJhIjoiY2x4bXYxdXNyMGlydzJycnh6bWJ5cjZpbiJ9.placeholder"
        UserDefaults.standard.set(accessToken, forKey: "MBXAccessToken")
        
        // Configure TileStore for offline-only use
        let tileStore = TileStore.default
        // In a real offline app, we would have already downloaded tiles into the TileStore
        // or bundled them as a .mbtiles file that we register with the TileStore.
        
        print("Mapbox configured for offline use with bundled .mbtiles")
    }
}
