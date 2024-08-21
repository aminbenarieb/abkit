// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "abkit",
    products: [
        .library(
            name: "ABKit",
            targets: ["ABCore"]
        ),
        .library(
            name: "ABCV",
            targets: ["ABCV"]
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
            name: "ABCV",
            dependencies: []
        ),
        .target(
            name: "ABUtils",
            dependencies: []
        )
    ]
)