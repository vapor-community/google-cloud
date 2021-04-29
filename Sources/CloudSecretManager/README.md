# GoogleCloudSecretManagerAPI

## Getting Started
If you only need to use the [Google Cloud Secret Manager API](https://cloud.google.com/storage/), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [
            //...
            .product(name: "CloudSecretManager", package: "google-cloud"),
        ]),
    ]
```

Now you can setup the configuration for any GCP API globally via `Application`.

In `configure.swift`

```swift
 import CloudSecretManager
 
 app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration(projectId: "myprojectid-12345",
 credentialsFile: "~/path/to/service-account.json")
```
Next we setup the CloudSecretManager API configuration (specific to this API).

```swift
app.googleCloud.secretManager.configuration = .default()
```

Now we can start using the GoogleCloudSecretManager API
There's a handy extension on `Request` that you can use to get access to a secret manager client  via a property named `gcSecretManager`. 

```swift

func getCICDSecrets(_ req: Request) throws -> EventLoopFuture<String> {    
    req.gcSecretManager.secrets.access("my-secret-name", version: "latest")
    .map { $0.payload.decodedData! // returns the base64-decoded value of secret }
}
```
