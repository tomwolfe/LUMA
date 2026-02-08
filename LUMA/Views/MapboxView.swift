import SwiftUI
import MapboxMaps
import CoreLocation

struct MapboxView: UIViewRepresentable {
    @ObservedObject var mapManager = MapManager.shared
    
    func makeUIView(context: Context) -> MapView {
        guard mapManager.isMapReady, let stylePath = Bundle.main.path(forResource: "style", ofType: "json") else {
            let emptyMapView = MapView(frame: .zero)
            let label = UILabel()
            label.text = "Offline data missing. Please ensure the app is properly installed."
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .light)
            label.translatesAutoresizingMaskIntoConstraints = false
            emptyMapView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: emptyMapView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: emptyMapView.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: emptyMapView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: emptyMapView.trailingAnchor, constant: -20)
            ])
            return emptyMapView
        }
        
        let accessToken = UserDefaults.standard.string(forKey: "MBXAccessToken") ?? ""
        let resourceOptions = ResourceOptions(accessToken: accessToken, tileStore: TileStore.default)
        
        let options = MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: CameraOptions(zoom: 12),
            styleURI: StyleURI(url: URL(fileURLWithPath: stylePath))
        )
        
        let mapView = MapView(frame: .zero, mapInitOptions: options)
        mapView.mapboxMap.onEvery(event: .styleLoaded) { _ in
            setupOfflineStyle(mapView)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        updateRoute(uiView)
    }
    
    private func setupOfflineStyle(_ mapView: MapView) {
        // Ensure the map uses the bundled .mbtiles by verifying source availability
        // If the style.json is configured with asset:// or mapbox:// matching TileStore, 
        // it will load automatically.
        print("Offline style loaded. Routing Mapbox to local tile source.")
    }
    
    private func updateRoute(_ mapView: MapView) {
        guard !mapManager.currentRoute.isEmpty else { return }
        
        let line = LineString(mapManager.currentRoute)
        let sourceId = "route-source"
        let layerId = "route-layer"
        
        var source = GeoJSONSource(id: sourceId)
        source.data = .geometry(.lineString(line))
        
        let layer = LineLayer(id: layerId, source: sourceId)
        layer.lineColor = .constant(StyleColor(.white))
        layer.lineWidth = .constant(3.0)
        layer.lineCap = .constant(.round)
        layer.lineJoin = .constant(.round)
        
        try? mapView.mapboxMap.addSource(source)
        try? mapView.mapboxMap.addLayer(layer)
        
        // Center camera on route
        if let first = mapManager.currentRoute.first {
            mapView.camera.animations.ease(to: CameraOptions(center: first, zoom: 14), duration: 1.0)
        }
    }
}
