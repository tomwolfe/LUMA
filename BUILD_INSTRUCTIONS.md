# Build Instructions for LUMA

This document explains how to set up and build the LUMA project on a clean machine.

## Prerequisites

1.  **Xcode**: Ensure you have Xcode 15+ installed.
2.  **Homebrew Dependencies**: OSRM requires some tools to be available on your host machine for the build process.
    ```bash
    brew install cmake ninja
    ```

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd LUMA
```

## Step 2: Download Offline Data

LUMA requires pre-processed map and routing data. 

1.  **Create the data directories**:
    ```bash
    mkdir -p osrm_data
    ```
2.  **Download the Data Pack**:
    Download the `LUMA-Data-v1.zip` from our [latest release](https://github.com/luma-navigation/data/releases/latest).
3.  **Place the Files**:
    *   **Map Tiles**: Move `sf.mbtiles`, `paris.mbtiles`, and `tokyo.mbtiles` to `LUMA/Resources/`.
    *   **Routing Data**: Move all `.osrm.*` files (e.g., `sf.osrm.hsgr`, etc.) to the `osrm_data/` directory at the root of the project.

## Step 3: Run the Setup Script

The setup script builds the OSRM engine and bundles the routing data into the app's dependencies.

```bash
# This will take 5-10 minutes.
./setup.sh
```

## Step 4: Open in Xcode

You can open the project by opening the `Package.swift` file in Xcode, or by opening the folder in Xcode.

```bash
open Package.swift
```

## Step 4: Configure Mapbox Token (Optional)

LUMA uses Mapbox for offline map rendering. To use your own token:
1.  Open `LUMA/Info.plist`.
2.  Add a key `MBXAccessToken` with your Mapbox Public Token.

## Step 5: Build and Run

1.  Select the `LUMA` target and an iOS Simulator or Device.
2.  Press `Cmd + R` to build and run.

### Troubleshooting

*   **OSRM.xcframework not found**: Ensure you ran `./OSRM-iOS/build.sh` successfully. Check that `OSRM-iOS/OSRM.xcframework` exists.
*   **Module not found**: If Xcode doesn't see `OSRM-iOS`, try `File > Packages > Reset Package Caches`.
