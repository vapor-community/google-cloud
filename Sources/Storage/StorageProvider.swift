//
//  GoogleCloudStorageProvider.swift
//  GoogleCloudProvider
//
//  Created by Brian Hatfield on 7/26/18.
//

import Vapor
import GoogleCloudProviderCore

public final class GoogleCloudStorageProvider: Provider {

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
