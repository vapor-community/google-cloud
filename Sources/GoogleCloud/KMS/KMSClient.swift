//
//  KMSClient.swift
//  GoogleCloudProvider
//
//  Created by Andrei Popa on 11/07/18.
//

import Vapor





public struct KMSScope {
    /// preferred because it supports the principle of least privilege
    public static let defaultScope = "https://www.googleapis.com/auth/cloudkms"
}






public final class GoogleCloudKMSClient: ServiceType {
    
    public var api: GoogleKMSAPI


    public init(providerconfig: GoogleCloudProviderConfig, client: Client) throws {
        let env = ProcessInfo.processInfo.environment
        
        // Locate the credentials to use for this client. In order of priority:
        // - Environment Variable Specified Credentials (GOOGLE_APPLICATION_CREDENTIALS)
        // - GoogleCloudProviderConfig's .serviceAccountCredentialPath (optionally configured)
        // - Application Default Credentials, located in the constant
        let credentialPath = env["GOOGLE_APPLICATION_CREDENTIALS"] ??
            providerconfig.serviceAccountCredentialPath ??
        "~/.config/gcloud/application_default_credentials.json"
        
        // project location
        guard let location = env["GOOGLE_LOCATION"] else {
            throw CloudKMSError.missingEnvironment(variable: "GOOGLE_LOCATION")
        }
        
        // credentials
        let credentials = try GoogleServiceAccountCredentials(contentsOfFile: credentialPath)
        // token
        let refreshableToken = OAuthServiceAccount(credentials: credentials, scopes: [KMSScope.defaultScope], httpClient: client)
        
        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - GoogleCloudProviderConfig's .project (optionally configured)
        let projectId = env["PROJECT_ID"] ?? providerconfig.project ?? refreshableToken.credentials.projectId
        

        // prepare generic request
        let kmsRequest = GoogleCloudKMSRequest(httpClient: client, oauth: refreshableToken, project: projectId, location: location)
        
        // initialize API
        api = GoogleKMSAPI(request: kmsRequest)
    }

    // ==================================================================
    // service
    // ==================================================================
    
    public static var serviceSupports: [Any.Type] { return [GoogleCloudKMSClient.self] }

    public static func makeService(for worker: Container) throws -> GoogleCloudKMSClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        return try GoogleCloudKMSClient(providerconfig: providerConfig, client: client)
    }
}
