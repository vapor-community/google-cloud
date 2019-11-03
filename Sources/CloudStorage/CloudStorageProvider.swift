//
//  CloudStorageProvider.swift
//  
//
//  Created by Andrew Edwards on 11/2/19.
//

import Vapor
@_exported import Core
@_exported import Storage

public final class CloudStorageProvider: Provider {
    public init() {}
    public func register(_ app: Application) {
        app.register(GoogleCloudStorageClient.self) { app in
            let credentialsConfig = app.make(GoogleCloudCredentialsConfiguration.self)
            let storageConfig = app.make(GoogleCloudStorageConfiguration.self)
            return try GoogleCloudStorageClient(configuration: credentialsConfig,
                                                storageConfig: storageConfig,
                                                eventLoop: app.make())
        }
    }
}
