# GoogleCloudTranslationAPI

## Getting Started
If you only need to use the [Google Cloud Translation API](https://cloud.google.com/translate), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [
            //...
            .product(name: "CloudTranslation", package: "google-cloud"),
        ]),
    ]
```

Now you can setup the configuration for any GCP API globally via `Application`.

In `configure.swift`

```swift
 import CloudTranslation
 
 app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration(projectId: "myprojectid-12345",
 credentialsFile: "~/path/to/service-account.json")
```
Next we setup the CloudTranslation API configuration (specific to this API).

```swift
app.googleCloud.translation.configuration = .default()
```

Now we can start using the GoogleCloudTranslation API
There's a handy extension on `Request` that you can use to get access to a translation client via a property named `gcTranslation`. 

```swift
func translateText(_ req: Request) throws -> EventLoopFuture<String> {    
    req.gcTranslation.translate(text: "Hello World", source: "en", target: "es")
    .map { $0.data.translations.first!.translatedText! // returns the spanish translation }
}
```
