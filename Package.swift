// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "xccheck",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "5.0.0-rc2"))
    ],
    targets: [
        .target(
            name: "xccheck",
            dependencies: ["Utility", "xcodeproj"]),
    ]
)
