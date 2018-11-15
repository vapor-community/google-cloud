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

public protocol StorageClient: ServiceType {
    var bucketAccessControl: BucketAccessControlAPI { get set }
    var buckets: StorageBucketAPI { get set }
    var channels: ChannelsAPI { get set }
    var defaultObjectAccessControl: DefaultObjectACLAPI { get set }
    var objectAccessControl: ObjectAccessControlsAPI { get set }
    var notifications: StorageNotificationsAPI { get set }
    var object: StorageObjectAPI { get set }
}

public final class GoogleCloudStorageClient: StorageClient {
    public var bucketAccessControl: BucketAccessControlAPI
    public var buckets: StorageBucketAPI
    public var channels: ChannelsAPI
    public var defaultObjectAccessControl: DefaultObjectACLAPI
    public var objectAccessControl: ObjectAccessControlsAPI
    public var notifications: StorageNotificationsAPI
    public var object: StorageObjectAPI

    init(providerconfig: GoogleCloudProviderConfig, storageConfig: GoogleCloudStorageConfig, client: Client) throws {
        let env = ProcessInfo.processInfo.environment

        // Locate the credentials to use for this client. In order of priority:
        // - Environment Variable Specified Credentials (GOOGLE_APPLICATION_CREDENTIALS)
        // - GoogleCloudProviderConfig's .serviceAccountCredentialPath (optionally configured)
        // - Application Default Credentials, located in the constant
        let preferredCredentialPath = env["GOOGLE_APPLICATION_CREDENTIALS"] ??
                                  providerconfig.serviceAccountCredentialPath ??
                                  "~/.config/gcloud/application_default_credentials.json"

        // A token implementing OAuthRefreshable. Loaded from credentials defined above.
        let refreshableToken = try OAuthCredentialLoader.getRefreshableToken(credentialFilePath: preferredCredentialPath,
                                                                             withConfig: storageConfig, andClient: client)

        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - GoogleCloudProviderConfig's .project (optionally configured)
        guard let projectId = env["PROJECT_ID"] ?? (refreshableToken as? OAuthServiceAccount)?.credentials.projectId ?? storageConfig.project else {
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

    public static var serviceSupports: [Any.Type] { return [StorageClient.self] }

    public static func makeService(for worker: Container) throws -> GoogleCloudStorageClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        let storageConfig = try worker.make(GoogleCloudStorageConfig.self)
        return try GoogleCloudStorageClient(providerconfig: providerConfig, storageConfig: storageConfig, client: client)
    }
}
