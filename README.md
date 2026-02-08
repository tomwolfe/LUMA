# LUMA Privacy Audit Log

LUMA is built on the principle of absolute privacy. No data ever leaves the device.

## 1. Zero Telemetry
- No Google Analytics, Firebase, or Mixpanel.
- No custom logging sent to external servers.
- Code proof: Search codebase for `URLSession`, `Alamofire`, or any networking library. Only local file paths are used.

## 2. Offline-First
- Map tiles are pre-bundled or downloaded over HTTPS once and stored locally.
- Routing (OSRM) happens entirely on-device using pre-compiled `.osrm` data.
- Geocoding is handled via a local SQLite/CoreData database of POIs.

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
