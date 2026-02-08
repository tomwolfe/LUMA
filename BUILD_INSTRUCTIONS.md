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

## Step 2: Build OSRM for iOS

OSRM is a C++ library that must be cross-compiled for iOS. We provide a script that automates this using Mason for dependencies. **Running this script is mandatory as it generates the `OSRM.xcframework` required by the `OSRM-iOS` Swift package.**

```bash
# This will take 5-10 minutes depending on your machine.
# It clones OSRM, downloads iOS dependencies (Boost, TBB, etc.),
# builds libosrm.a for ARM64, and creates OSRM.xcframework in the OSRM-iOS/ directory.
./OSRM-iOS/build.sh
```

## Step 3: Open in Xcode

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
