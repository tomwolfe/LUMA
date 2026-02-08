# LUMA

LUMA is a minimalist, privacy-first navigation app designed for urban exploration. It transforms navigation into a serene, offline journey by eliminating digital clutter and external dependencies. Powered entirely by locally bundled data, LUMA ensures your exploration is anonymous, uninterrupted, and deeply personal.

## 🚀 Quick Start

To build and run LUMA on your machine:

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd LUMA
    ```

2.  **Run the automated setup:**
    This script builds the OSRM C++ routing engine for iOS ARM64 and configures all Swift Package dependencies.
    ```bash
    ./setup.sh
    ```
    *This process takes approximately 5-10 minutes.*

3.  **Open in Xcode:**
    ```bash
    open Package.swift
    ```

4.  **Configure Mapbox (Optional):**
    To use your own Mapbox account for offline SDK validation, add your public access token to `LUMA/Info.plist` under the key `MBXAccessToken`.

For detailed build instructions, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md).

---

## 🛠 Core Architecture

LUMA is built on a foundation of local processing and zero telemetry:

*   **Routing:** Powered by a custom-built [OSRM](https://project-osrm.org/) engine, cross-compiled for iOS ARM64 and integrated via a Swift-C++ bridge (`OSRMBridge`).
*   **Maps:** Renders high-fidelity offline map tiles using the Mapbox Maps SDK, loaded from pre-bundled `.mbtiles` files for San Francisco, Paris, and Tokyo.
*   **POI Discovery:** High-speed local geocoding via a SQLite database containing 50,000+ Points of Interest per city.
*   **Haptics:** A custom `HapticManager` delivers intuitive turn-by-turn feedback through precise taps (1-tap left, 2-tap right, 3-tap U-turn).
*   **Ambient Sounds:** Immersive, locally stored audio loops (Rain, Ocean, City) enhance the journey without requiring an internet connection.

---

## 🛡 LUMA Privacy Audit Log

Privacy is not a feature; it is the foundation. LUMA guarantees your data never leaves your device.

### 1. Zero Telemetry
*   **No** Google Analytics, Firebase, Mixpanel, or any external analytics.
*   **No** custom logging sent to external servers.
*   **Code Proof:** The entire codebase contains zero references to `URLSession`, `Alamofire`, or any networking library. Only local file paths are used.

### 2. Offline-First
*   **Map tiles** are pre-bundled and stored locally as `.mbtiles`.
*   **Routing** (OSRM) happens entirely on-device using pre-compiled `.osrm` data.
*   **Geocoding** is handled exclusively via a local SQLite database of POIs.

### 3. No Identity
*   **No** `identifierForVendor` or `advertisingIdentifier` is accessed.
*   **No** user accounts, logins, or profiles.
*   **No** cloud sync (iCloud/CloudKit is explicitly disabled).

### 4. Ephemeral Location
*   Location permissions are requested **"While Using the App"** only.
*   GPS coordinates are used solely for real-time navigation display and are **NEVER** stored to disk or transmitted.
*   Background location is explicitly disabled in `Info.plist`.

### 5. Permissions Checklist
- [x] Location: "While Using" only.
- [x] Haptics: Local only.
- [x] Audio: Local playback only.
- [ ] Camera: NOT USED.
- [ ] Contacts: NOT USED.
- [ ] Bluetooth: NOT USED.
- [ ] Motion: NOT USED.

---

## 📱 User Experience

LUMA's interface is a study in minimalism:
*   **Home Screen:** A pulsing, minimalist compass icon.
*   **Search:** A full-screen, monospaced text field for ultra-light, local POI matching.
*   **Navigation:** Clean ETA, battery status, and a single, unobtrusive route line.
*   **Journey Mode:** A gesture-activated overlay for ambient sound control.
*   **Arrival:** A serene, high-res image fade-in, followed by an automatic return to the home screen.

The entire app is designed for dark mode, with the custom `LumaMono` font ensuring pixel-perfect readability.

---

"The details are not the details. They make the design." — Charles Eames