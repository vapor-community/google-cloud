# GoogleCloudStorageAPI

## Getting Started
If you only need to use the [Google Cloud Storage API](https://cloud.google.com/storage/), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud-provider.git", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [  "Vapor",
                                                    "CloudStorage",
                                                  ]),
    ]
```

Now you can setup the configuration for any GCP API globally via `Application`.

In `configure.swift`

```swift
 import CloudStorage
 
 app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration(projectId: "myprojectid-12345",
 credentialsFile: "~/path/to/service-account.json")
```
Next we setup the CloudStorage API configuration (specific to this API).

```swift
app.googleCloud.storage.configuration = .default()
```

Now we can start using the CloudStorage API
There's a handy extension on `Request` that you can use to get access to a cloud storage client
`req.gcs`

```swift
struct UploadRequest: Content {
    var data: Data
    var filename: String
}

func uploadImage(_ req: Request) throws {
    let upload = try req.content.decode(UploadRequest.self)
    
    
    req.gcs.object.createSimpleUpload(bucket: "vapor-cloud-storage-demo",
                                      data: upload.data,
                                      name: upload.filename,
                                      contentType: "image/jpeg").flatMap { uploadedObject in
        print(uploadedObject.mediaLink) // prints the download link for the image.
    }
}
```
