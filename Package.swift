// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "mac-tooltip",
    products: [
        .executable(name: "mac-tooltip", targets: ["mac-tooltip"]),
        .library(name: "MacTooltipCore", targets: ["MacTooltipCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MacTooltipCore",
            dependencies: []),
        .executableTarget(
            name: "mac-tooltip",
            dependencies: ["MacTooltipCore"],
            path: ".",
            sources: ["main.swift"]),
        .testTarget(
            name: "MacTooltipCoreTests",
            dependencies: ["MacTooltipCore"]),
    ]
)
