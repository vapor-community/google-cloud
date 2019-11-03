# CloudStorageProvider

## Getting Started
If you only need to use the [Google Cloud Storage API](https://cloud.google.com/storage/), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud-provider.git", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [// Other dependencies
                                                    "CloudStorage",
                                                  ]),
    ]
```

Now you can register the `CloudCredentialsConfiguraton` and the `CloudStorageConfiguration`.

In `Configure.swift`

```swift
 import CloudStorage
 
 // register the credentials configuration which is used by all APIs
 app.register(GoogleCloudCredentialsConfiguration.self) { _ in
     return GoogleCloudCredentialsConfiguration(project: "myprojectid-12345",
                                                credentialsFile: "~/path/to/service-account.json")
 }
 
 // Register the CloudStorage Configuraton.
 app.register(GoogleCloudStorageConfiguration.self) { _ in
    return GoogleCloudStorageConfiguration.defult()
 }
 
// Add the CloudStorageProvder
 app.provider(CloudStorageProvider())
```

Now we can start using the CloudStorage API
We do that by making a `GoogleCloudStorageClient` object that's already configured
from the `CloudStorageProvider` we setup above.

```swift
struct UploadRequest: Content {
    var data: Data
    var filename: String
}

func uploadImage(_ req: Request) throws {
    let upload = try req.content.decode(UploadRequest.self)
    
    let storageClient = app.make(GoogleCloudStorageClient.self)
    storageClient.object.createSimpleUpload(bucket: "vapor-cloud-storage-demo",
                                            data: upload.data,
                                            name: upload.filename,
                                            contentType: "image/jpeg").flatMap { uploadedObject in
        print(uploadedObject.mediaLink) // prints the download link for the image.
    }
}
```
