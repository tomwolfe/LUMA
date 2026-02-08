# LUMA Project Plan (MVP — One Week)

## ✅ Completed (Day 1)
- **App Architecture:** SwiftUI-based state machine (Home → Search → Navigation → Arrival).
- **Home Screen:** Pulsing minimalist compass icon with high-precision animation.
- **Search Flow:** Ultra-light monospaced full-screen search with local POI matching.
- **Navigation UI:** ETA, Battery, and minimalist route/dot display.
- **Journey Mode:** Gesture-based overlay with ambient sound controls.
- **Haptic Engine:** Manager for 1-tap, 2-tap, and 3-tap turn signals.
- **Privacy First:** Privacy Audit Log and strictly local-only manager structures.
- **Mock Data:** Initial POI datasets for San Francisco, Paris, and Tokyo.

## 🛠 In Progress (Days 2-4)
- **Mapbox Native Integration:** Configuring the SDK for zero-network tile loading from bundled `.mbtiles`.
- **OSRM Compilation:** Cross-compiling OSRM for ARM64 (iOS) and integrating via a Swift-C++ bridge.
- **Local POI DB:** Moving from mock data to a full SQLite-backed database of 50k POIs per city.
- **Ambient Sounds:** Sourcing and bundling high-fidelity loops for Rain, Ocean, and City.

## 🚀 Final Hardening (Days 5-7)
- **Arrival Ritual:** Implementing the high-res image fetcher (local assets).
- **Battery Optimization:** GPS duty-cycle tuning for <3% hourly drain.
- **Performance Profiling:** Ensuring <0.8s launch time and <80MB memory footprint.
- **UI Polish:** Finalizing the *LumaMono* font integration and pixel-perfect transitions.

---
"The details are not the details. They make the design." — Charles Eames
