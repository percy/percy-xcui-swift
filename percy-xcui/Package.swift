// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Percy XCUI Swift",
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
            dependencies: [],
            path: "Sources/PercyXcui",
            resources: [
                .copy("Resources/devices.json")
            ]
        )
    ]
)
