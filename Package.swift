// swift-tools-version:5.3
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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", from: "0.5.1")
    ],
    targets: [
        .target(
            name: "Helper",
            dependencies: [
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .target(
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
            dependencies: ["Models"]
        )
    ]
)
