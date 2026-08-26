// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-terminal-input",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Terminal Input",
            targets: ["Terminal Input"]
        ),
        .library(
            name: "Terminal Input Test Support",
            targets: ["Terminal Input Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-terminal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-input.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Terminal Input",
            dependencies: [
                .product(name: "Terminal", package: "swift-terminal"),
                .product(name: "Input", package: "swift-input"),
                .product(name: "ASCII", package: "swift-ascii"),
            ]
        ),
        .target(
            name: "Terminal Input Test Support",
            dependencies: [
                "Terminal Input",
                .product(name: "Input Test Support", package: "swift-input"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Terminal Input Tests",
            dependencies: [
                "Terminal Input",
                "Terminal Input Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
