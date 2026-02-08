import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var lastLocation: CLLocation?
    @Published var currentCity: String?
    
    private var lastHeading: CLLocationDirection?
    private var isStraightPathCount = 0
    private let straightPathThreshold = 5 // Number of updates with similar heading to consider "straight"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .otherNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        
        // Reverse geocode to get city
        geocodeCity(for: location)
        
        // Dynamic GPS duty-cycle optimization
        optimizeBattery(for: location)
    }
    
    private func geocodeCity(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.currentCity = city
                }
            }
        }
    }
    
    private func optimizeBattery(for location: CLLocation) {
        let speed = location.speed // meters per second
        
        if speed < 0.5 {
            // Stationary: Lower accuracy and increase distance filter
            if locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters {
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.distanceFilter = 10 // 10 meters
                print("LocationManager: Stationary mode enabled")
            }
        } else {
            // Moving: Check for straight path
            if let lastH = lastHeading {
                let headingDiff = abs(location.course - lastH)
                if headingDiff < 5.0 { // Less than 5 degrees change
                    isStraightPathCount += 1
                } else {
                    isStraightPathCount = 0
                }
            }
            
            lastHeading = location.course
            
            if isStraightPathCount > straightPathThreshold {
                // On a long straight path: Lower accuracy slightly to save battery
                if locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters {
                    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                    locationManager.distanceFilter = 50 // 50 meters
                    print("LocationManager: Straight path optimization enabled")
                }
            } else {
                // Turning or complex path: High accuracy required
                if locationManager.desiredAccuracy != kCLLocationAccuracyBest {
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.distanceFilter = kCLDistanceFilterNone
                    print("LocationManager: High accuracy mode enabled")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
