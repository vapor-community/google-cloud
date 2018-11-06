//
//  StorageClient.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/16/18.
//

import Vapor



enum GoogleCloudKMSError: Error {
    case projectIdMissing
    case unknownError
}



public final class GoogleCloudKMSClient {
    
    public var api: GoogleKMSAPI


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
        guard let projectId = env["PROJECT_ID"] ?? providerconfig.project ?? (refreshableToken as? OAuthServiceAccount)?.credentials.projectId else {
            throw GoogleCloudStorageClientError.projectIdMissing
        }

        // TODO: extract location into env["LOCATION"]
        let kmsRequest = GoogleCloudKMSRequest(httpClient: client, oauth: refreshableToken, project: projectId, location: "europe-west4")

        // initialize API
        api = GoogleKMSAPI(request: kmsRequest)
    }


    public static func makeService(for worker: Container) throws -> GoogleCloudKMSClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        return try GoogleCloudKMSClient(providerconfig: providerConfig, client: client)
    }
}
