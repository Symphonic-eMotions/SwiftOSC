//
//  Package.swift
//  
//
//  Created by Frans-Jan Wind on 26/09/2025.
//


// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftOSC",
    platforms: [
        .iOS(.v13),      // pas aan naar wens (bijv. .v14 of hoger)
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "SwiftOSC", targets: ["SwiftOSC"])
    ],
    targets: [
        // C target met alleen het UDP C-bestand
        .target(
            name: "CYUDPSocket",
            path: "Framework/SwiftOSC/Communication/ysocket",
            sources: ["yudpsocket.c"]
        ),
        // Swift target met alle Swift-bestanden, exclusief het C-bestand
        .target(
            name: "SwiftOSC",
            dependencies: ["CYUDPSocket"],
            path: "Framework/SwiftOSC",
            exclude: ["Communication/ysocket/yudpsocket.c"]
        ),
        // Optioneel: testtarget als je tests toevoegt
        // .testTarget(
        //     name: "SwiftOSCTests",
        //     dependencies: ["SwiftOSC"],
        //     path: "Tests/SwiftOSCTests"
        // )
    ]
)
