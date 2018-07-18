//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor

public struct GoogleCloudStorageClient: ServiceType {
    public var bucketAccessControl: GoogleBucketAccessControlAPI
    public var buckets: GoogleStorageBucketAPI
    public var channels: GoogleChannelsAPI
    public var defaultObjectAccessControl: GoogleDefaultObjectACLAPI
    public var objectAccessControl: GoogleObjectAccessControlsAPI
    public var notifications: GoogleStorageNotificationsAPI
    public var object: GoogleStorageObjectAPI
    
    init(providerconfig: GoogleCloudProviderConfig, client: Client) throws {
        let refreshableToken: OAuthRefreshable

        if let credentialPath = providerconfig.serviceAccountCredentialPath {
            let credentials = try GoogleServiceAccountCredentials(fromFile: credentialPath)

            refreshableToken = OAuthServiceAccount(credentials: credentials, scopes: [StorageScope.fullControl], httpClient: client)
        } else {
            let adcPath = NSString(string: "~/.config/gcloud/application_default_credentials.json").expandingTildeInPath
            let credentials = try GoogleApplicationDefaultCredentials(fromFile: adcPath)
            refreshableToken = OAuthApplicationDefault(credentials: credentials, httpClient: client)
        }
        
        let storageRequest = GoogleCloudStorageRequest(httpClient: client, oauth: refreshableToken, project: providerconfig.project)
        
        bucketAccessControl = GoogleBucketAccessControlAPI(request: storageRequest)
        buckets = GoogleStorageBucketAPI(request: storageRequest)
        channels = GoogleChannelsAPI(request: storageRequest)
        defaultObjectAccessControl = GoogleDefaultObjectACLAPI(request: storageRequest)
        objectAccessControl = GoogleObjectAccessControlsAPI(request: storageRequest)
        notifications = GoogleStorageNotificationsAPI(request: storageRequest)
        object = GoogleStorageObjectAPI(request: storageRequest)
    }
    
    public static func makeService(for worker: Container) throws -> GoogleCloudStorageClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        
        return try GoogleCloudStorageClient(providerconfig: providerConfig, client: client)
    }
}
