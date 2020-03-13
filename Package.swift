// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "google-cloud",
    platforms: [
       .macOS(.v10_15)
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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", .exact("1.0.0-alpha.9"))
    ],
    targets: [
        .target(
            name: "GoogleCloud",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "google-cloud-kit", package: "google-cloud-kit"),
            ]),
        
        .target(
            name: "CloudStorage",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "google-cloud-storage", package: "google-cloud-kit"),
        ]),
    ]
)
