// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SwiftPackageAcknowledgement",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "spm-ack", targets: ["SwiftPackageAcknowledgement"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.6"),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .branch("Promise"))
    ],
    targets: [
        .target(
            name: "SwiftPackageAcknowledgement",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"), "FoundationExtensions"]
        )
    ]
)
