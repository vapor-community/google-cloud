//
//  GoogleCloudProvider.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor
@_exported import Core
@_exported import Storage
// New APIs added to GoogleCloudKit should be exported here.

public final class GoogleCloudProvider: Provider {
    private let apis: [GoogleCloudAPI]
    
    /// - Parameter apis: An array containing  `GoogleCloudAPI`s that you want to use and that have also been configured to use.
    public init(apis: [GoogleCloudAPI]) {
        self.apis = apis
    }
    
    public func register(_ app: Application) {
        app.register(GoogleCloudClient.self) { app in
            return try GoogleCloudClient(apis: self.apis, app: app)
        }
    }
}

/** The GoogleCloudClient acts as a single point of access for interacting with one or more GCP APIs that have been configured.
 
    ```
        let client: GoogleCloudClient = GoogleCloudClient(...)
        client.storage.buckets // etc.
        client.pubsub // etc.
        client.gcpAPI // etc.
    ```
*/
public class GoogleCloudClient {
    private var _storage: GoogleCloudStorageClient?
    
    /// An instance of the CloudStorageClient used to access the various CloudStorage APIs.
    public var storage: GoogleCloudStorageClient {
        guard let storageClient = _storage else {
            fatalError("Failed to create CloudStorageClient. Make sure you specify '.storage' when creating the 'GoogleCloudProvider'.")
        }
        return storageClient
    }
    
    init(apis: [GoogleCloudAPI], app: Application) throws {
        let credentialsConfig = app.make(GoogleCloudCredentialsConfiguration.self)
        for api in apis {
            switch api {
            case .storage:
                let storageConfig = app.make(GoogleCloudStorageConfiguration.self)
                _storage = try GoogleCloudStorageClient(configuration: credentialsConfig,
                                                        storageConfig: storageConfig,
                                                        eventLoop: app.make())
            }
        }
    }
}
