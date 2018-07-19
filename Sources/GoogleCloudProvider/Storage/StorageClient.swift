//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor

enum GoogleCloudStorageClientError: Error {
    case projectIdMissing
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

        // A token implementing OAuthRefreshable. Set via the priority order below.
        let refreshableToken: OAuthRefreshable

        // An optional configuredProjectId, available in OAuthServiceAccounts only. Set
        // by the same token priority order below.
        var configuredProjectId: String?

        // Locate the credentials to use for this client. In order of priority:
        // - Environment Variable Specified Credentials (GOOGLE_APPLICATION_CREDENTIALS)
        // - GoogleCloudProviderConfig's .serviceAccountCredentialPath (optionally configured)
        // - Application Default Credentials, located in the constant
        if let credentialPath = env["GOOGLE_APPLICATION_CREDENTIALS"] {
            let credentials = try GoogleServiceAccountCredentials(contentsOfFile: credentialPath)

            configuredProjectId = credentials.projectId
            refreshableToken = OAuthServiceAccount(credentials: credentials, scopes: [StorageScope.fullControl], httpClient: client)
        } else if let credentialPath = providerconfig.serviceAccountCredentialPath {
            let credentials = try GoogleServiceAccountCredentials(contentsOfFile: credentialPath)

            configuredProjectId = credentials.projectId
            refreshableToken = OAuthServiceAccount(credentials: credentials, scopes: [StorageScope.fullControl], httpClient: client)
        } else {
            let credentials = try GoogleApplicationDefaultCredentials(contentsOfFile: "~/.config/gcloud/application_default_credentials.json")
            refreshableToken = OAuthApplicationDefault(credentials: credentials, httpClient: client)
        }

        // projectId set by the below priority ordering.
        let projectId: String

        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - GoogleCloudProviderConfig's .project (optionally configured)
        // - The project ID from a service account's credentials file (only available in service account credentials)
        if let project = env["PROJECT_ID"] {
            projectId = project
        } else if let project = providerconfig.project {
            projectId = project
        } else if let project = configuredProjectId {
            projectId = project
        } else {
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
