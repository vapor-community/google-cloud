//
//  StorageConfig.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/21/18.
//

import Vapor

public struct GoogleCloudStorageConfig: Service {
    public let scope: [String]

    public init(scope: [String]) {
        self.scope = scope
    }
}

