//
//  StorageConfig.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/21/18.
//

import Vapor

public struct GoogleCloudStorageConfig: Service {
    public let email: String
    public let scope: [String]
}

