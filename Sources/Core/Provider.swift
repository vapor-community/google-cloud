//
//  StorageBucket.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public enum GoogleCloudError: Error {
    case projectIdMissing
    case unknownError
}

public struct GoogleCloudConfig: Service {
    public let project: String?
    public let serviceAccountCredentialPath: String?

    public init(project: String?, credentialFile: String? = nil) {
        self.project = project
        self.serviceAccountCredentialPath = credentialFile
    }
}
