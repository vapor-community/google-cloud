//
//  QueryParameters.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor
// TODO: Use these when time comes
public enum StorageBucketCreateQueryParameter: String, Content {
    /// Apply a predefined set of access controls to this bucket.
    case predefinedAcl
    /// Apply a predefined set of default object access controls to this bucket.
    case predefinedDefaultObjectAcl
    /// Set of properties to return. Defaults to noAcl, unless the bucket resource specifies acl or defaultObjectAcl properties, when it defaults to full.
    case projection
    /// The project to be billed for this request.
    case userProject
}
