//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public struct GoogleCloudProviderConfig: Service {
    let project: String
    let serviceAccountCredentialPath: String?

    public init(project: String, credentialFile: String? = nil) {
        self.project = project
        self.serviceAccountCredentialPath = credentialFile
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
