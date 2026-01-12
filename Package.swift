// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlotSwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PlotSwift",
            targets: ["PlotSwift"]
        ),
    ],
    targets: [
        .target(
            name: "PlotSwift",
            path: "Sources/PlotSwift"
        ),
        .testTarget(
            name: "PlotSwiftTests",
            dependencies: ["PlotSwift"]
        ),
    ]
)
