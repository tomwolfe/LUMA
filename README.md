# LUMA: Meso-scale Discovery Engine

LUMA is a minimalist, privacy-first navigation app designed for urban exploration. It features offline-only routing, locally bundled map tiles, and ambient soundscapes to enhance the journey.

## 🚀 Quick Start

To build and run LUMA on your machine:

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd LUMA
    ```

2.  **Run the automated setup**:
    This script builds the OSRM C++ library for iOS ARM64 and configures the Swift Package dependencies.
    ```bash
    ./setup.sh
    ```

3.  **Open in Xcode**:
    ```bash
    open Package.swift
    ```

4.  **Configure Mapbox (Optional)**:
    Set your `MBXAccessToken` in `LUMA/Info.plist` if you wish to use your own Mapbox account for the offline SDK validation.

For more detailed build information, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md).

## 🛠 Core Architecture

-   **Routing**: Powered by a custom-built [OSRM](https://project-osrm.org/) engine cross-compiled for iOS and integrated via a Swift-C++ bridge (`OSRMBridge`).
-   **Maps**: Renders offline `.mbtiles` using the Mapbox Maps SDK.
-   **POI Discovery**: High-speed local SQLite database for offline geocoding.
-   **Haptics**: Custom `HapticManager` for turn-by-turn tactile feedback without looking at the screen.

---

# LUMA Privacy Audit Log

LUMA is built on the principle of absolute privacy. No data ever leaves the device.

## 1. Zero Telemetry
- No Google Analytics, Firebase, or Mixpanel.
- No custom logging sent to external servers.
- Code proof: Search codebase for `URLSession`, `Alamofire`, or any networking library. Only local file paths are used.

## 2. Offline-First
- Map tiles are pre-bundled and stored locally in `.mbtiles` format.
- Routing (OSRM) happens entirely on-device using pre-compiled `.osrm` data.
- Geocoding is handled via a local SQLite database of POIs.

## 3. No Identity
- No `identifierForVendor` or `advertisingIdentifier` is accessed.
- No user accounts, logins, or profiles.
- No cloud sync (iCloud/CloudKit is disabled).

## 4. Ephemeral Location
- Location permissions are requested only "While Using the App".
- GPS coordinates are used for real-time navigation display and are NEVER stored to disk or transmitted.
- Background location is explicitly disabled in `Info.plist`.

## 5. Permissions Checklist
- [x] Location: "While Using" only.
- [x] Haptics: Local only.
- [x] Audio: Local playback only.
- [ ] Camera: NOT USED.
- [ ] Contacts: NOT USED.
- [ ] Bluetooth: NOT USED.
- [ ] Motion: NOT USED.

---
"Privacy is not a feature; it is the foundation."