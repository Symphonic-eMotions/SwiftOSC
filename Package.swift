//
//  Package.swift
//  
//
//  Created by Frans-Jan Wind on 27/09/2025.
//


// swift-tools-version: 5.9
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
        .target(
            name: "SwiftOSC",
            path: "Framework/iOS/SwiftOSC"
        )
    ]
)
