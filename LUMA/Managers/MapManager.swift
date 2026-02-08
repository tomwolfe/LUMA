import Foundation
import CoreLocation
import MapboxMaps
import UIKit

class MapManager: ObservableObject {
    static let shared = MapManager()
    
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var instructions: [String] = []
    @Published var isMapReady: Bool = true
    @Published var configurationError: String?
    
    private var osrmBridge: OSRMBridge?
    private var currentCity: String?
    private let locationManager = LocationManager.shared
    
    private init() {}
    
    func validateData(for city: String) -> Bool {
        let cityName = city.lowercased().replacingOccurrences(of: " ", with: "_")
        
        // Check for .mbtiles
        guard let mbtilesPath = Bundle.main.path(forResource: cityName, ofType: "mbtiles") else {
            print("Missing .mbtiles for \(city)")
            return false
        }
        
        if !verifyFileIntegrity(at: mbtilesPath) {
            print("Corrupted .mbtiles for \(city)")
            return false
        }
        
        // Check for .osrm files (at least .hsgr)
        let fileName = "\(cityName).osrm"
        var hsgrPath: String? = Bundle.main.path(forResource: fileName, ofType: "hsgr")
        if hsgrPath == nil {
            for bundle in Bundle.allBundles {
                if let path = bundle.path(forResource: fileName, ofType: "hsgr") {
                    hsgrPath = path
                    break
                }
            }
        }
        
        guard let finalHsgrPath = hsgrPath else {
            print("Missing .osrm data for \(city)")
            return false
        }
        
        if !verifyFileIntegrity(at: finalHsgrPath) {
            print("Corrupted .osrm data for \(city)")
            return false
        }
        
        return true
    }

    private func verifyFileIntegrity(at path: String) -> Bool {
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfItem(atPath: path),
              let fileSize = attributes[.size] as? UInt64 else {
            return false
        }
        
        // Basic integrity check: File must be > 1KB
        if fileSize < 1024 {
            return false
        }
        
        // Advanced: Check for magic bytes/header
        if let fileHandle = FileHandle(forReadingAtPath: path) {
            let header = fileHandle.readData(ofLength: 8)
            fileHandle.closeFile()
            
            if path.hasSuffix(".mbtiles") {
                // SQLite magic header: "SQLite format 3\0"
                let sqliteMagic = "SQLite f".data(using: .ascii)
                if header.prefix(8) != sqliteMagic {
                    return false
                }
            }
            // For OSRM, we could check specific headers if known, 
            // but at least we've checked existence, size and readability.
        }
        
        return true
    }

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
        
        // Use real-time location from LocationManager
        guard let userLocation = locationManager.lastLocation?.coordinate else {
            print("User location not available yet")
            return
        }
        
        let start = userLocation
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = bridge.calculateRoute(from: start, to: destination)
            
            if result.success {
                let routeValues = result.coordinates ?? []
                let coordinates = routeValues.compactMap { value -> CLLocationCoordinate2D? in
                    var coord = CLLocationCoordinate2D()
                    value.getValue(&coord)
                    return coord
                }
                
                let instructions = result.instructions ?? []
                
                DispatchQueue.main.async {
                    self.currentRoute = coordinates
                    self.instructions = instructions
                }
            } else {
                print("Routing error: \(result.errorMessage ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.configurationError = result.errorMessage
                }
            }
        }
    }
    
    private func loadOSRM(for city: String) {
        let cityName = city.lowercased().replacingOccurrences(of: " ", with: "_")
        let fileName = "\(cityName).osrm"
        
        // Search in all bundles to find the OSRM data
        var hsgrPath: String? = Bundle.main.path(forResource: fileName, ofType: "hsgr")
        
        if hsgrPath == nil {
            for bundle in Bundle.allBundles {
                if let path = bundle.path(forResource: fileName, ofType: "hsgr") {
                    hsgrPath = path
                    break
                }
            }
        }
        
        guard let finalPath = hsgrPath else {
            print("Could not find OSRM data files for \(city). Expected \(fileName).hsgr in bundle.")
            DispatchQueue.main.async {
                self.isMapReady = false
            }
            return
        }
        
        // Strip the .hsgr extension to get the base path required by OSRMBridge
        let basePath = (finalPath as NSString).deletingPathExtension
        osrmBridge = OSRMBridge(initWithOSRMFile: basePath)
        currentCity = city
    }
    
    func configureOfflineMaps() {
        // Read the Mapbox access token from Info.plist as required
        let token = Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String
        
        if token == nil || token == "" || token == "YOUR_MAPBOX_ACCESS_TOKEN" {
            DispatchQueue.main.async {
                self.configurationError = "Mapbox Access Token is missing or invalid in Info.plist. Please add a valid token under the key MBXAccessToken."
                self.isMapReady = false
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
                self.configurationError = "Some map data files (.mbtiles) are missing from the bundle."
                self.isMapReady = false
            }
        }
        
        print("Mapbox configured for offline use with bundled .mbtiles for all cities")
    }
}
