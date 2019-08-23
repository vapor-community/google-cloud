# GoogleCloudProvider

![Swift](http://img.shields.io/badge/swift-5.1-brightgreen.svg)
![Vapor](http://img.shields.io/badge/vapor-4.0-brightgreen.svg)

### GoogleCloudProvider is a Vapor wrapper around [GoogleCloudKit](https://github.com/vapor-community/GoogleCloudKit)


## Installation

In your `Package.swift` file, add the following

```swift
.package(url: "https://github.com/vapor-community/google-cloud-provider.git", from: "1.0.0-alpha.1")
```

Register the credentials configuration (required) and the provider in  `Configure.swift`

```swift
 import GoogleCloud
 
 // register the credentials configuration which is used by all APIs
 s.register(GoogleCloudCredentialsConfiguration.self) { _ in
     return GoogleCloudCredentialsConfiguration(project: "myprojectid-12345",
                                                credentialsFile: "~/path/to/service-account.json")
 }
 
 // Register an API specific configuration. CloudStorage in this example.
 s.register(GoogleCloudStorageConfiguration.self) { _ in 
    return GoogleCloudStorageConfiguration.defult()
 }
 
 s.provider(GoogleCloudProvider())
```

Example usage
```swift

struct UploadRequest: Content {
    var data: Data
    var filename: String
}

func uploadImage(_ req: Request) throws {
    let upload = try req.content.decode(UploadRequest.self)
    
    let storageClient = try container.make(GoogleCloudStorageClient.self)
    storageClient.object.createSimpleUpload(bucket: "vapor-cloud-storage-demo",
                                            data: upload.data,
                                            name: upload.filename,
                                            contentType: "image/jpeg").flatMap { uploadedObject in
        print(uploadedObject.mediaLink) // prints the download link for the image.
    }
}
```

### A More detailed guide can be found [here](https://github.com/vapor-community/GoogleCloudKit).

