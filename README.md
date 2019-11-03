# GoogleCloudProvider

![Swift](http://img.shields.io/badge/swift-5.1-brightgreen.svg)
![Vapor](http://img.shields.io/badge/vapor-4.0-brightgreen.svg)

### GoogleCloudProvider is a Vapor wrapper around [GoogleCloudKit](https://github.com/vapor-community/GoogleCloudKit)


## Installation

In your `Package.swift` file, add the following

```swift
.package(url: "https://github.com/vapor-community/google-cloud-provider.git", from: "1.0.0-beta")
```

Register the credentials configuration (required) and the provider in  `Configure.swift`

```swift
 import GoogleCloud
 
 // register the credentials configuration which is used by all APIs
 app.register(GoogleCloudCredentialsConfiguration.self) { _ in
     return GoogleCloudCredentialsConfiguration(project: "myprojectid-12345",
                                                credentialsFile: "~/path/to/service-account.json")
 }
 
 // Register an API specific configuration. CloudStorage in this example.
 app.register(GoogleCloudStorageConfiguration.self) { _ in 
    return GoogleCloudStorageConfiguration.defult()
 }
 
 // Configure more API configurations that you want to use.
 
 // Add the GoogleCloudProvider and choose the APIs you want to include
 app.provider(GoogleCloudProvider(apis: [.storage, .pubsub, ...])
```

Now we can access the `GoogleCloudClient` which has access to all the APIs we've configured.

```swift
    let cloudClient = app.make(GoogleCloudClient.self)
    // Use the Storage api to list the buckets.
    cloudClient.storage.buckets.list().flatMap { buckets in
        print(buckets.items.last.name) 
    }
```

### Supported APIs
[x] [CloudStorage](/Sources/CloudStorage/README.md) 

### A More detailed guide can be found [here](https://github.com/vapor-community/GoogleCloudKit).

