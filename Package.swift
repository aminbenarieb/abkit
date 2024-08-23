// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "abkit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ABKit",
            targets: ["ABCore"]
        ),
        .library(
            name: "ABVision",
            targets: ["ABVision"]
        ),
        .library(
            name: "ABUtils",
            targets: ["ABUtils"]
        ),
    ],
    targets: [
        .target(
            name: "ABCore",
            dependencies: []
        ),
        .target(
            name: "ABVision",
            dependencies: []
        ),
        .target(
            name: "ABUtils",
            dependencies: []
        )
    ]
)
