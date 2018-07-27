// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloud",
    products: [
        .library(
            name: "GoogleCloudStorage",
            targets: ["GoogleCloudStorage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc")
    ],
    targets: [
        .target(
            name: "GoogleCloudStorage",
            dependencies: ["GoogleCloudCore"],
            path: "Sources/Storage"
        ),

        .target(
            name: "GoogleCloudCore",
            dependencies: ["Vapor", "JWT"],
            path: "Sources/Core"
        ),
    ]
)
