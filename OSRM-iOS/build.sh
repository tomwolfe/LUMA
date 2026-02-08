#!/bin/bash
set -e

# OSRM-iOS Build Script
# This script builds OSRM for iOS ARM64 and creates an XCFramework for Swift Package Manager.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PACKAGE_DIR="$SCRIPT_DIR"
BUILD_DIR="$PACKAGE_DIR/build_temp"
OSRM_BACKEND_DIR="$BUILD_DIR/osrm-backend"
mkdir -p "$BUILD_DIR"

echo "--- 1. Downloading iOS toolchain ---"
if [ ! -f "$BUILD_DIR/ios.toolchain.cmake" ]; then
    curl -Lo "$BUILD_DIR/ios.toolchain.cmake" https://raw.githubusercontent.com/leetal/ios-cmake/master/ios.toolchain.cmake
fi

echo "--- 2. Cloning OSRM ---"
if [ ! -d "$OSRM_BACKEND_DIR" ]; then
    git clone --depth 1 --branch v5.26.0 https://github.com/Project-OSRM/osrm-backend.git "$OSRM_BACKEND_DIR"
fi

echo "--- 3. Configuring OSRM with Mason ---"
mkdir -p "$OSRM_BACKEND_DIR/build"
cd "$OSRM_BACKEND_DIR/build"

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$BUILD_DIR/ios.toolchain.cmake" \
    -DPLATFORM=OS64 \
    -DENABLE_MASON=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_BITCODE=OFF \
    -DBUILD_TOOLS=OFF \
    -DBUILD_EXAMPLE=OFF \
    -DENABLE_NODE_BINDINGS=OFF

echo "--- 4. Building OSRM ---"
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

echo "--- 5. Preparing XCFramework structure ---"
# We need a clean headers directory for the XCFramework
XCF_HEADERS="$BUILD_DIR/headers"
mkdir -p "$XCF_HEADERS/osrm"
cp -R "$OSRM_BACKEND_DIR/include/osrm/" "$XCF_HEADERS/osrm/"
# Copy variant headers (dependency)
mkdir -p "$XCF_HEADERS/variant"
cp -R "$OSRM_BACKEND_DIR/third_party/variant/include/mapbox/" "$XCF_HEADERS/variant/"

echo "--- 6. Merging static libraries ---"
# Collect all static libs from build and mason_packages
mkdir -p "$BUILD_DIR/libs"
find . -name "*.a" -exec cp {} "$BUILD_DIR/libs/" \;
# Also find libs in mason_packages if any were missed
find "$OSRM_BACKEND_DIR/build/mason_packages" -name "*.a" -exec cp {} "$BUILD_DIR/libs/" \; 2>/dev/null || true

cd "$BUILD_DIR/libs"
# Merge them using libtool
# We exclude some system libs if they were caught by accident, but mostly we want all boost, tbb, osrm.
libtool -static -o libosrm_combined.a *.a

echo "--- 7. Bundling OSRM data files ---"
# Create a Resources directory in the package's target folder
RESOURCES_DIR="$PACKAGE_DIR/Sources/OSRM-iOS/Resources"
mkdir -p "$RESOURCES_DIR"

# The data files must be prepared in the 'osrm_data' directory at the project root.
# This avoids circular dependencies and ensures a clean build process.
DATA_SOURCE_DIR="$PACKAGE_DIR/../osrm_data"

echo "Copying OSRM data files from $DATA_SOURCE_DIR to $RESOURCES_DIR..."

if [ -d "$DATA_SOURCE_DIR" ] && [ "$(ls -A "$DATA_SOURCE_DIR" 2>/dev/null)" ]; then
    cp "$DATA_SOURCE_DIR"/*.osrm.* "$RESOURCES_DIR/"
    echo "✅ Successfully bundled OSRM data files."
else
    echo "⚠️  WARNING: No OSRM data files found in $DATA_SOURCE_DIR."
    echo "Please download the required .osrm.* files (sf.osrm.*, paris.osrm.*, tokyo.osrm.*)"
    echo "and place them in the 'osrm_data/' directory at the root of the project."
    echo "Refer to BUILD_INSTRUCTIONS.md for details."
fi

echo "--- 8. Creating XCFramework ---"
rm -rf "$PACKAGE_DIR/OSRM.xcframework"
xcodebuild -create-xcframework \
    -library "$BUILD_DIR/libs/libosrm_combined.a" \
    -headers "$XCF_HEADERS" \
    -output "$PACKAGE_DIR/OSRM.xcframework"

echo "--- OSRM.xcframework created and data files bundled successfully! ---"