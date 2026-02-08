// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OSRM-iOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OSRM-iOS",
            targets: ["OSRM-iOS"]),
    ],
    targets: [
        .target(
            name: "OSRM-iOS",
            dependencies: ["OSRM"],
            resources: [
                .process("Resources")
            ]),
        .binaryTarget(
            name: "OSRM",
            path: "OSRM.xcframework")
    ]
)