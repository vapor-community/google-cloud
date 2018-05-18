//
//  RequestBody.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor
// TODO: Use these when time comes
public enum StorageBucketCreateRequestBody: String, Content {
    /// Access controls on the bucket, containing one or more bucketAccessControls Resources.
    case acl
    /// The bucket's billing configuration.
    case billing
    /// The bucket's Cross-Origin Resource Sharing (CORS) configuration.
    case cors
    /// Default access controls to apply to new objects when no ACL is provided.
    case defaultObjectAcl
    /// User-provided labels, in key/value pairs.
    case labels
    /// The bucket's lifecycle configuration. See lifecycle management for more information.
    case lifecycle
    case location
    case logging
    case storageClass
    case versioning
    case website
}

