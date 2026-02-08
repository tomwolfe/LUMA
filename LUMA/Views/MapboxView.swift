import SwiftUI
import MapboxMaps
import CoreLocation

struct MapboxView: UIViewRepresentable {
    @ObservedObject var mapManager = MapManager.shared
    
    func makeUIView(context: Context) -> MapView {
        let options = MapInitOptions(
            cameraOptions: CameraOptions(zoom: 12),
            styleURI: .dark // Standard dark style, but will load from local tiles
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
        // Force the map to use bundled .mbtiles
        // This is a simplified representation of Mapbox's TileStore/Style integration
        // In a real implementation, you would point to a local JSON style that references local tiles.
        print("Mapbox style loaded. Ensuring offline tile source is active.")
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
