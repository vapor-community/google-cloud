//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor

public struct GoogleCloudStorageClient: ServiceType {
    public var buckets: GoogleStorageBucketAPI
    public var bucketAccessControl: GoogleBucketAccessControlAPI
    public var channels: GoogleChannelsAPI
    
    init(providerconfig: GoogleCloudProviderConfig, storageconfig: GoogleCloudStorageConfig, client: Client) {
        let oauthRequester = GoogleOAuth(serviceEmail: storageconfig.email, scopes: storageconfig.scope, privateKey: providerconfig.privateKey, httpClient: client)
        let storageRequest = GoogleCloudStorageRequest(httpClient: client, oauth: oauthRequester, project: providerconfig.project)
        
        buckets = GoogleStorageBucketAPI(request: storageRequest)
        bucketAccessControl = GoogleBucketAccessControlAPI(request: storageRequest)
        channels = GoogleChannelsAPI(request: storageRequest)
    }
    
    public static func makeService(for worker: Container) throws -> GoogleCloudStorageClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        let storageConfig = try worker.make(GoogleCloudStorageConfig.self)
        
        return GoogleCloudStorageClient(providerconfig: providerConfig, storageconfig: storageConfig, client: client)
    }
}
