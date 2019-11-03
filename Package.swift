// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloud",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "GoogleCloud",
            targets: ["GoogleCloud"]),
        .library(
            name: "CloudStorage",
            targets: ["CloudStorage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor-community/GoogleCloudKit.git", from: "1.0.0-alpha")
    ],
    targets: [
        .target(
            name: "GoogleCloud",
            dependencies: ["Vapor", "GoogleCloudKit"]),
        
        .target(
            name: "CloudStorage",
            dependencies: ["Vapor", "GoogleCloudStorage"]),
    ]
)
