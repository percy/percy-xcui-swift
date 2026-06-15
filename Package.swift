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
            // Note: This contains inner folder as path so that other clients can use this repo as a package
            path: "percy-xcui/Sources"),
        .testTarget(
            name: "PercyXcuiTests",
            dependencies: ["PercyXcui"],
            // Shares the one canonical suite that also lives in percy-xcui/Package.swift.
            path: "percy-xcui/Tests/PercyXcuiTests")
    ]
)
