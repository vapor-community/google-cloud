// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleCloud",

    // Export each main target (Storage, PubSub, KMS, etc) as a separate library,
    // which allows end-users of this library to only depend on and compile the targets
    // they prefer to use.
    products: [
        // Exports OAuth, Credentials, and the main provider class. Generally not
        // useful except for use as a migration step from other libraries into this
        // provider.
        .library(
            name: "GoogleCloudCore",
            targets: ["GoogleCloudCore"]),

        // Exports Storage, a Google Cloud Storage API wrapper.
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
