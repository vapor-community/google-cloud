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
        .library(
            name: "CloudDatastore",
            targets: ["CloudDatastore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", from: "1.0.0-rc")
    ],
    targets: [
        .target(
            name: "GoogleCloud",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GoogleCloudKit", package: "google-cloud-kit"),
            ]),
        
        .target(
            name: "CloudStorage",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GoogleCloudStorage", package: "google-cloud-kit"),
                .target(name: "GoogleCloud")
        ]),
        .target(
            name: "CloudDatastore",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GoogleCloudDatastore", package: "google-cloud-kit"),
                .target(name: "GoogleCloud")
        ]),
    ]
)
