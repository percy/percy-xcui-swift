// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Percy XCUI Swift",
    products: [
        .library(
            name: "PercyXcui",
            targets: ["PercyXcui"],
            resources: [.process("Resources/devices.json")])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PercyXcui",
            dependencies: [],
            resources: [.process("Resources/devices.json")])
    ]
)
