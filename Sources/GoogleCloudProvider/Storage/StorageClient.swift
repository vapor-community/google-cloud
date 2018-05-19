//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor

public struct GoogleCloudStorageClient: ServiceType {
    public var buckets: GoogleStorageBucketAPI
    
    init(providerconfig: GoogleCloudProviderConfig, storageconfig: GoogleCloudStorageConfig, client: Client) {
        
        let oauthRequester = GoogleOAuth(serviceEmail: storageconfig.email, scopes: storageconfig.scope, privateKey: providerconfig.privateKey, httpClient: client)
        
        let bucketRequest = GoogleCloudStorageBucketRequest(httpClient: client, oauth: oauthRequester, project: providerconfig.project)
        buckets = GoogleStorageBucketAPI(request: bucketRequest)
    }
    
    public static func makeService(for worker: Container) throws -> GoogleCloudStorageClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        let storageConfig = try worker.make(GoogleCloudStorageConfig.self)
        
        return GoogleCloudStorageClient(providerconfig: providerConfig, storageconfig: storageConfig, client: client)
    }
}

// grab a provider config to get projectid and private key
// create the single OAuthRequest type giving it scope, private key, email etc.
// pass that oauthrequest to a request for a single route
// eg BucketRequest(oauthRequester, projectid)
// eg ObjectRequest(oauthRequester, projectid)
// and every route gets their own request from above
// once all routes for a Service are initialized just return the service.
