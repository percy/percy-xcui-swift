// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Percy XCUI Swift",
    // macOS platform is declared so the host unit-test suite (Swift Testing)
    // can run via `swift test`. The shipped library remains iOS-targeted; this
    // does not change what iOS clients build.
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "PercyXcui",
            targets: ["PercyXcui"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PercyXcui",
            dependencies: []
        ),
        .testTarget(
            name: "PercyXcuiTests",
            dependencies: ["PercyXcui"],
            // Canonical test sources live inside this nested package root so both
            // Package.swift files can reference the same suite.
            path: "Tests/PercyXcuiTests"
        )
    ]
)
