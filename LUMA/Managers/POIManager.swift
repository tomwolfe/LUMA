import Foundation
import CoreData

struct POI: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let latitude: Double
    let longitude: Double
}

class POIManager: ObservableObject {
    @Published var results: [POI] = []
    
    // Mock data for MVP
    private let mockData = [
        POI(name: "Golden Gate Bridge", city: "San Francisco", latitude: 37.8199, longitude: -122.4783),
        POI(name: "Ferry Building", city: "San Francisco", latitude: 37.7955, longitude: -122.3937),
        POI(name: "Eiffel Tower", city: "Paris", latitude: 48.8584, longitude: 2.2945),
        POI(name: "Louvre Museum", city: "Paris", latitude: 48.8606, longitude: 2.3376),
        POI(name: "Shibuya Crossing", city: "Tokyo", latitude: 35.6595, longitude: 139.7005),
        POI(name: "Tokyo Tower", city: "Tokyo", latitude: 35.6586, longitude: 139.7454)
    ]
    
    func search(query: String) {
        if query.isEmpty {
            results = []
            return
        }
        
        results = mockData.filter { 
            $0.name.lowercased().contains(query.lowercased()) || 
            $0.city.lowercased().contains(query.lowercased())
        }
    }
}
