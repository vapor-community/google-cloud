//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor

enum GoogleCloudStorageClientError: Error {
    case projectIdMissing
    case unknownError
}

public struct GoogleCloudStorageClient: ServiceType {
    public var bucketAccessControl: GoogleBucketAccessControlAPI
    public var buckets: GoogleStorageBucketAPI
    public var channels: GoogleChannelsAPI
    public var defaultObjectAccessControl: GoogleDefaultObjectACLAPI
    public var objectAccessControl: GoogleObjectAccessControlsAPI
    public var notifications: GoogleStorageNotificationsAPI
    public var object: GoogleStorageObjectAPI
    
    init(providerconfig: GoogleCloudProviderConfig, client: Client) throws {
        let env = ProcessInfo.processInfo.environment

        // Locate the credentials to use for this client. In order of priority:
        // - Environment Variable Specified Credentials (GOOGLE_APPLICATION_CREDENTIALS)
        // - GoogleCloudProviderConfig's .serviceAccountCredentialPath (optionally configured)
        // - Application Default Credentials, located in the constant
        let preferredCredentialPath = env["GOOGLE_APPLICATION_CREDENTIALS"] ??
                                  providerconfig.serviceAccountCredentialPath ??
                                  "~/.config/gcloud/application_default_credentials.json"

        // A token implementing OAuthRefreshable. Loaded from credentials defined above.
        let refreshableToken = try OAuthCredentialLoader.getRefreshableToken(credentialFilePath: preferredCredentialPath, withClient: client)

        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - GoogleCloudProviderConfig's .project (optionally configured)
        guard let projectId = env["PROJECT_ID"] ?? providerconfig.project else {
            throw GoogleCloudStorageClientError.projectIdMissing
        }

        let storageRequest = GoogleCloudStorageRequest(httpClient: client, oauth: refreshableToken, project: projectId)
        
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
