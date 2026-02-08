#!/bin/bash
set -e

echo "🚀 Setting up LUMA project..."

# 1. Build OSRM-iOS
echo "📦 Building OSRM-iOS dependency..."
chmod +x OSRM-iOS/build.sh
./OSRM-iOS/build.sh

# 2. Update Swift Packages
echo "🔄 Updating Swift packages..."
swift package update

echo "✅ Setup complete!"
echo "👉 You can now open the project in Xcode: open Package.swift"
