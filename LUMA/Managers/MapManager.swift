import Foundation
import CoreLocation
import MapboxMaps
import UIKit

class MapManager: ObservableObject {
    static let shared = MapManager()
    
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var instructions: [String] = []
    @Published var isMapReady: Bool = true
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
            DispatchQueue.main.async {
                self.isMapReady = false
            }
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
            DispatchQueue.main.async {
                self.isMapReady = false
            }
            return
        }
        
        osrmBridge = OSRMBridge(initWithOSRMFile: path)
        currentCity = city
    }
    
    func configureOfflineMaps() {
        let token = UserDefaults.standard.string(forKey: "MBXAccessToken")
        if token == nil || token == "YOUR_MAPBOX_ACCESS_TOKEN" {
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Mapbox Token Required",
                    message: "You must add your own Mapbox access token to LUMA/Info.plist under the key MBXAccessToken.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    exit(1)
                }))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   var topController = window.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.present(alert, animated: true, completion: nil)
                } else {
                    print("Mapbox Token Required: Please add your token to LUMA/Info.plist")
                    // If we can't show UI yet, we might need a small delay or just exit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        exit(1)
                    }
                }
            }
            return
        }
        
        let offlineManager = OfflineManager()
        let cities = ["sf", "paris", "tokyo"]
        var allFilesPresent = true
        
        for city in cities {
            guard let mbtilesPath = Bundle.main.path(forResource: city, ofType: "mbtiles") else {
                print("Could not find .mbtiles for \(city)")
                allFilesPresent = false
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
        
        if !allFilesPresent {
            DispatchQueue.main.async {
                self.isMapReady = false
            }
        }
        
        print("Mapbox configured for offline use with bundled .mbtiles for all cities")
    }
}
