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
        .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0"),
        .package(path: "./OSRM-iOS"),
    ],
    targets: [
        .target(
            name: "LUMA",
            dependencies: [
                .product(name: "MapboxMaps", package: "mapbox-maps-ios"),
                .product(name: "OSRM-iOS", package: "OSRM-iOS")
            ],
            path: "LUMA"),
        .testTarget(
            name: "LUMATests",
            dependencies: ["LUMA"],
            path: "LUMATests"),
    ]
)
