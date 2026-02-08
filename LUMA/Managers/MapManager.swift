import Foundation
import CoreLocation
import MapboxMaps

class MapManager: ObservableObject {
    static let shared = MapManager()
    
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var instructions: [String] = []
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
            let routeData = bridge.calculateRoute(from: start, to: destination)
            
            let routeValues = routeData["coordinates"] as? [NSValue] ?? []
            let coordinates = routeValues.compactMap { value -> CLLocationCoordinate2D? in
                var coord = CLLocationCoordinate2D()
                value.getValue(&coord)
                return coord
            }
            
            let instructions = routeData["instructions"] as? [String] ?? []
            
            DispatchQueue.main.async {
                self.currentRoute = coordinates
                self.instructions = instructions
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
        // Initialize Mapbox with a placeholder token
        let accessToken = "pk.eyJ1IjoibHVtYS1kZXYiLCJhIjoiY2x4bXYxdXNyMGlydzJycnh6bWJ5cjZpbiJ9.placeholder"
        UserDefaults.standard.set(accessToken, forKey: "MBXAccessToken")
        
        let offlineManager = OfflineManager()
        let cities = ["sf", "paris", "tokyo"]
        
        for city in cities {
            guard let mbtilesPath = Bundle.main.path(forResource: city, ofType: "mbtiles") else {
                print("Could not find .mbtiles for \(city)")
                continue
            }
            
            // Import bundled .mbtiles into the TileStore
            offlineManager.importTileRegion(forId: "\(city)-region", path: mbtilesPath) { result in
                switch result {
                case .success:
                    print("Successfully imported offline tiles for \(city) from \(mbtilesPath)")
                case .failure(let error):
                    print("Failed to import offline tiles for \(city): \(error)")
                }
            }
        }
        
        print("Mapbox configured for offline use with bundled .mbtiles for all cities")
    }
}
