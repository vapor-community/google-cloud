//
//  GoogleCloudProvider.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//
import Vapor
@_exported import GoogleCloudKit

public final class GoogleCloudProvider: Provider {
    
    public init() {}
    
    public func register(_ s: inout Services) {
        s.register(GoogleCloudStorageClient.self) { container in
            let credentialsConfig = try container.make(GoogleCloudCredentialsConfiguration.self)
            let storageConfig = try container.make(GoogleCloudStorageConfiguration.self)
            return try GoogleCloudStorageClient(configuration: credentialsConfig,
                                                storageConfig: storageConfig,
                                                eventLoop: container.eventLoop)
        }
    }
}
