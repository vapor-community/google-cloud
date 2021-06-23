#  GoogleCloudPubSubAPI

## Getting Started
If you only need to use the [Google Cloud PubSub API](https://cloud.google.com/pubsub), then this guide will help you get started.

In your `Package.swift` file, make sure you have the following dependencies and targets

```swift
dependencies: [
        //...
        .package(url: "https://github.com/vapor-community/google-cloud.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [
            //...
            .product(name: "CloudPubSub", package: "google-cloud"),
        ]),
    ]
```

Now you can setup the configuration for any GCP API globally via `Application`.

In `configure.swift`

```swift
import CloudPubSub
 
 app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration(projectId: "myprojectid-12345",
 credentialsFile: "~/path/to/service-account.json")
```
Next we setup the CloudlPubSub API configuration (specific to this API).

```swift
app.googleCloud.pubsub.configuration = .default()
```

Now we can start using the GoogleCloudPubSub API
There's a handy extension on `Request` that you can use to get access to a pubsub client via a property named `gcPubsub`. 

```swift
func publishMessage(_ req: Request) throws -> EventLoopFuture<[String]> {
    guard let topicId = req.parameters.get("topicId") else {
        throw Abort(.badRequest, reason:"Missing Topic ID from the request")
    }
    
    try PubSubMessage.validate(content: req)
    let message = try req.content.decode(PubSubMessage.self)
    
    return req.gcPubSub.pubSubTopic.publish(topicId: topicId,
                                            data: message.data,
                                            attributes: nil,
                                            orderingKey: nil)
        .map { response in
            return response.messageIds
    }
}

struct PubSubMessage: Content {
    let data: String
    let attributes: [String: String]?
    let orderingKey: String?
}
```

