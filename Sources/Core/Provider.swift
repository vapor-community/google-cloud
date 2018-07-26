//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public enum GoogleCloudProviderError: Error {
    case projectIdMissing
    case unknownError
}

public struct GoogleCloudProviderConfig: Service {
    public let project: String?
    public let serviceAccountCredentialPath: String?

    public init(project: String?, credentialFile: String? = nil) {
        self.project = project
        self.serviceAccountCredentialPath = credentialFile
    }
}
