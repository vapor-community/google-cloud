//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public struct GoogleCloudProviderConfig: Service {
    public let project: String
    public let privateKey: String
    
    public init(projectId: String, rsaPrivateKey: String) {
        project = projectId
        privateKey = rsaPrivateKey
    }
}


public final class GoogleCloudProvider: Provider {
    
    public static let repositoryName = "google-cloud-provider"
    
    public init() {}
    
    public func boot(_ worker: Container) throws {}
    
    
    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
    
    public func register(_ services: inout Services) throws {
        services.register(GoogleCloudStorageClient.self)
    }
}
