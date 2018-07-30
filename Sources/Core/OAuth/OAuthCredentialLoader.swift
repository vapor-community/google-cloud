//
//  OAuthCredentialLoader.swift
//  GoogleCloud
//
//  Created by Brian Hatfield on 7/19/18.
//

import Vapor

public class OAuthCredentialLoader {
    let credentialPath: String
    let scopes: [String]?
    let client: Client

    public func getRefreshableToken() throws -> OAuthRefreshable {
        if let credentials = try? GoogleServiceAccountCredentials(contentsOfFile: credentialPath) {
            if let scopes = self.scopes {
                return OAuthServiceAccount(credentials: credentials, scopes: scopes, httpClient: client)
            }

            throw CredentialLoadError.noScopesDefined
        }

        if let credentials = try? GoogleApplicationDefaultCredentials(contentsOfFile: credentialPath) {
            return OAuthApplicationDefault(credentials: credentials, httpClient: client)
        }

        throw CredentialLoadError.noValidFileError
    }

    public init(config providerConfig: GoogleCloudConfig, scopes: [String]?, client: Client) {
        let env = ProcessInfo.processInfo.environment

        // Locate the credentials to use for this client. In order of priority:
        // - Environment Variable Specified Credentials (GOOGLE_APPLICATION_CREDENTIALS)
        // - GoogleCloudConfig's .serviceAccountCredentialPath (optionally configured)
        // - Application Default Credentials, located in the constant
        self.credentialPath = env["GOOGLE_APPLICATION_CREDENTIALS"] ??
            providerConfig.serviceAccountCredentialPath ??
            "~/.config/gcloud/application_default_credentials.json"

        self.scopes = scopes
        self.client = client
    }
}
