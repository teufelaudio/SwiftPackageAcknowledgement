// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "SwiftPackageAcknowledgement",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "spm-ack", targets: [
            "Models",
            "SwiftPackageAcknowledgement"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", from: "0.6.2")
    ],
    targets: [
        .target(
            name: "Helper",
            dependencies: [
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .executableTarget(
            name: "SwiftPackageAcknowledgement",
            dependencies: [
                "Helper",
                "Models",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                "Helper",
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .testTarget(
            name: "SwiftPackageAcknowledgementTests",
            dependencies: ["Models"],
            resources: [
                .copy("Resources/SwiftPackagePackageResolved.json"),
                .copy("Resources/XCWorkspacePackageResolved.json"),
            ]
        )
    ]
)
