// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LUMA",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "LUMA",
            targets: ["LUMA"]),
    ],
    dependencies: [
        // Mapbox dependency would go here if using SPM
        // .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "LUMA",
            dependencies: [],
            path: "LUMA"),
        .testTarget(
            name: "LUMATests",
            dependencies: ["LUMA"],
            path: "LUMATests"),
    ]
)
