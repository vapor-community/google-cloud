# GoogleCloudDatastoreAPI

## Getting Started
If you only need to use the [Google Cloud Datastore API](https://cloud.google.com/datastore/), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud.git", from: "1.0.0-rc"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [
            //...
            .product(name: "CloudDatastore", package: "google-cloud"),
        ]),
    ]
```

Now you can setup the configuration for any GCP API globally via `Application`.

In `configure.swift`

```swift
 import CloudDatastore
 
 app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration(projectId: "myprojectid-12345",
 credentialsFile: "~/path/to/service-account.json")
```
Next we setup the CloudDatastore API configuration (specific to this API).

```swift
app.googleCloud.datastore.configuration = .default()
```

Now we can start using the GoogleCloudDatastore API
There's a handy extension on `Request` that you can use to get access to a cloud datastore client  via a property named `gcDatastore`.

```swift

struct LookupRequest: Content {
    var name: String
}

func lookupEntities(_ req: Request) throws {
    let name = try req.content.decode(LookupRequest.self)

    let pathElement = PathElement(.name(name.name), kind: "MyEntity")
    let partitionId = PartitionId(projectId: "my-project")
    let key = Key(partitionId: partitionId, path: [pathElement])

    req.gcDatastore.project.lookup(keys: [key]).map { response in
        print(response.found.count) // prints 1 if entity exists
    }
}
```

