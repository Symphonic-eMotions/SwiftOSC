// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftOSC",
    platforms: [
        .iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v7)
    ],
    products: [
        .library(name: "SwiftOSC", targets: ["SwiftOSC"])
    ],
    targets: [
        // C target (C/ObjC/CPP-only)
        .target(
            name: "CYSockets",
            path: "Framework/CYSockets",
            publicHeadersPath: "include"
        ),
        // Swift target (Swift-only) that depends on the C target
        .target(
            name: "SwiftOSC",
            dependencies: ["CYSockets"],
            path: "Framework/SwiftOSC",
            exclude: ["Info.plist"]
        ),
    ]
)
