// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "xccheck",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.2.0"),
        .package(url: "https://github.com/appsquickly/XcodeEditor.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "xccheck",
            dependencies: ["Utility", "XcodeEditor"]),
    ]
)
