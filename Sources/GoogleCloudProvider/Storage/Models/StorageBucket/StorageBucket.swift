//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor
/// The Buckets resource represents a bucket in Google Cloud Storage. There is a single global namespace shared by all buckets. For more information, see Bucket Name Requirements.
public struct GoogleStorageBucket: GoogleCloudModel {
    /// The kind of item this is. For buckets, this is always storage#bucket.
    public var kind: String
    /// The ID of the bucket. For buckets, the id and name properties are the same.
    public var id: String
    /// The URI of this bucket.
    public var selfLink: String
    /// The project number of the project the bucket belongs to.
    public var projectNumber: String
    /// The name of the bucket.
    public var name: String
    /// The creation time of the bucket in RFC 3339 format.
    public var timeCreated: Date
    /// The modification time of the bucket in RFC 3339 format.
    public var updated: Date
    /// The metadata generation of this bucket.
    public var metageneration: String
    /// Access controls on the bucket, containing one or more bucketAccessControls Resources.
    public var acl: [BucketAccessControls]
    /// Default access controls to apply to new objects when no ACL is provided.
    public var defaultObjectAcl: [DefaultObjectACL]
    /// The owner of the bucket. This is always the project team's owner group.
    public var owner: Owner
    /// The location of the bucket. Object data for objects in the bucket resides in physical storage within this region. Defaults to US.
    public var location: String
    /// The bucket's website configuration, controlling how the service behaves when accessing bucket contents as a web site.
    public var website: Website
    /// The bucket's logging configuration, which defines the destination bucket and optional name prefix for the current bucket's logs.
    public var logging: Logging
    /// The bucket's versioning configuration.
    public var versioning: Versioning
    /// The bucket's Cross-Origin Resource Sharing (CORS) configuration.
    public var cors: [Cors]
    /// The bucket's lifecycle configuration. See lifecycle management for more information.
    public var lifecycle: Lifecycle
    /// User-provided labels, in key/value pairs.
    public var labels: [String: String]
    /// The bucket's default storage class, used whenever no storageClass is specified for a newly-created object. This defines how objects in the bucket are stored and determines the SLA and the cost of storage. Values include MULTI_REGIONAL, REGIONAL, STANDARD, NEARLINE, COLDLINE, and DURABLE_REDUCED_AVAILABILITY. If this value is not specified when the bucket is created, it will default to STANDARD.
    public var storageClass: String
    /// The bucket's billing configuration.
    public var billing: Billing
    /// HTTP 1.1 Entity tag for the bucket.
    public var etag: String
}

public struct BucketAccessControls: GoogleCloudModel {
    public var kind: String
    public var id: String
    public var selfLink: String
    public var bucket: String
    public var entity: String
    public var role: String
    public var email: String
    public var entityId: String
    public var domain: String
    public var projectTeam: ProjectTeam
    /// HTTP 1.1 Entity tag for the access-control entry.
    public var etag: String
}

public struct DefaultObjectACL: GoogleCloudModel {
    /// The kind of item this is. For object access control entries, this is always storage#objectAccessControl.
    public var kind: String
    /// The ID of the access-control entry.
    public var id: String
    /// The link to this access-control entry.
    public var selfLink: String
    /// The name of the bucket.
    public var bucket: String
    /// The name of the object, if applied to an object.
    public var object: String
    /// The content generation of the object, if applied to an object.
    public var generation: String
    /// The entity holding the permission.
    public var entity: String
    /// The access permission for the entity. Acceptable values are: "OWNER", "READER"
    public var role: String
    /// The email address associated with the entity, if any.
    public var email: String
    /// The ID for the entity, if any.
    public var entityId: String
    /// The domain associated with the entity, if any.
    public var domain: String
    /// The project team associated with the entity, if any.
    public var projectTeam: ProjectTeam
    /// HTTP 1.1 Entity tag for the access-control entry.
    public var etag: String
}

public struct ProjectTeam: GoogleCloudModel {
    /// The project number.
    public var projectNumber: String
    /// The team. Acceptable values are: "editors", "owners", "viewers"
    public var team: String
}

public struct Owner: GoogleCloudModel {
    /// The entity, in the form project-owner-projectId.
    public var entity: String
    /// The ID for the entity.
    public var entityId: String
}

public struct Website: GoogleCloudModel {
    /// If the requested object path is missing, the service will ensure the path has a trailing '/', append this suffix, and attempt to retrieve the resulting object. This allows the creation of index.html objects to represent directory pages.
    public var mainPageSuffix: String
    /// If the requested object path is missing, and any mainPageSuffix object is missing, if applicable, the service will return the named object from this bucket as the content for a 404 Not Found result.
    public var notFoundPage: String
}

public struct Logging: GoogleCloudModel {
    /// The destination bucket where the current bucket's logs should be placed.
    public var logBucket: String
    /// A prefix for log object names.
    public var logObjectPrefix: String
}

public struct Versioning: GoogleCloudModel {
    /// While set to true, versioning is fully enabled for this bucket.
    public var enabled: Bool
}

public struct Cors: GoogleCloudModel {
    /// The list of Origins eligible to receive CORS response headers. Note: "*" is permitted in the list of origins, and means "any Origin".
    public var origin: [String]
    /// The list of HTTP methods on which to include CORS response headers, (GET, OPTIONS, POST, etc) Note: "*" is permitted in the list of methods, and means "any method".
    public var method: [String]
    /// The list of HTTP headers other than the simple response headers to give permission for the user-agent to share across domains.
    public var responseHeader: [String]
    /// The value, in seconds, to return in the Access-Control-Max-Age header used in preflight responses.
    public var maxAgeSeconds: Int
}

public struct Lifecycle: GoogleCloudModel {
    /// A lifecycle management rule, which is made of an action to take and the condition(s) under which the action will be taken.
    public var rule: [Rule]
}

public struct Rule: GoogleCloudModel {
    /// The action to take.
    public var action: Action
    /// The condition(s) under which the action will be taken.
    public var condition: Condition
}

public struct Action: GoogleCloudModel {
    /// Type of the action. Currently, only Delete and SetStorageClass are supported. Acceptable values are: "Delete", "SetStorageClass"
    public var type: String
    /// Target storage class. Required iff the type of the action is SetStorageClass.
    public var storageClass: String
}

public struct Condition: GoogleCloudModel {
    /// Age of an object (in days). This condition is satisfied when an object reaches the specified age.
    public var age: Int
    /// A date in RFC 3339 format with only the date part (for instance, "2013-01-15"). This condition is satisfied when an object is created before midnight of the specified date in UTC.
    public var createdBefore: Date
    /// Relevant only for versioned objects. If the value is true, this condition matches live objects; if the value is false, it matches archived objects.
    public var isLive: Bool
    /// Objects having any of the storage classes specified by this condition will be matched. Values include MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, and DURABLE_REDUCED_AVAILABILITY.
    public var matchesStorageClass: [String]
    /// Relevant only for versioned objects. If the value is N, this condition is satisfied when there are at least N versions (including the live version) newer than this version of the object.
    public var numNewerVersions: Int
}

public struct Billing: GoogleCloudModel {
    /// When set to true, bucket is requester pays.
    public var requesterPays: Bool
}

public struct EmptyStorageBucketResponse: GoogleCloudModel {}
