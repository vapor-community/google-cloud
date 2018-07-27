//
//  StorageClient.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor
import GoogleCloudCore

public final class GoogleCloudStorageClient: ServiceType {
    public var bucketAccessControl: BucketAccessControlAPI
    public var buckets: StorageBucketAPI
    public var channels: ChannelsAPI
    public var defaultObjectAccessControl: DefaultObjectACLAPI
    public var objectAccessControl: ObjectAccessControlsAPI
    public var notifications: StorageNotificationsAPI
    public var object: StorageObjectAPI

    init(providerconfig: GoogleCloudConfig, client: Client) throws {
        let env = ProcessInfo.processInfo.environment

        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - GoogleCloudConfig's .project (optionally configured)
        guard let projectId = env["PROJECT_ID"] ?? providerconfig.project else {
            throw GoogleCloudError.projectIdMissing
        }

        let refreshableToken = try OAuthCredentialLoader(config: providerconfig, scopes: [StorageScope.fullControl], client: client).getRefreshableToken()
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
        let providerConfig = try worker.make(GoogleCloudConfig.self)

        return try GoogleCloudStorageClient(providerconfig: providerConfig, client: client)
    }
}
