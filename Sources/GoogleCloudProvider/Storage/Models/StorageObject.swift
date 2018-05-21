//
//  StorageObject.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/20/18.
//

import Vapor

public struct GoogleStorageObject: GoogleCloudModel {
    /// The kind of item this is. For objects, this is always storage#object.
    public var kind: String?
    /// The ID of the object, including the bucket name, object name, and generation number.
    public var id: String?
    /// The link to this object.
    public var selfLink: String?
    /// The name of the object. Required if not specified by URL parameter.
    public var name: String?
    /// The name of the bucket containing this object.
    public var bucket: String?
    /// The content generation of this object. Used for object versioning.
    public var generation: String?
    /// The version of the metadata for this object at this generation. Used for preconditions and for detecting changes in metadata. A metageneration number is only meaningful in the context of a particular generation of a particular object.
    public var metageneration: String?
    /// Content-Type of the object data. If an object is stored without a Content-Type, it is served as application/octet-stream.
    public var contentType: String?
    /// The creation time of the object in RFC 3339 format.
    public var timeCreated: Date?
    /// The modification time of the object metadata in RFC 3339 format.
    public var updated: Date?
    /// The deletion time of the object in RFC 3339 format. Will be returned if and only if this version of the object has been deleted.
    public var timeDeleted: Date?
    /// Storage class of the object.
    public var storageClass: String?
    /// The time at which the object's storage class was last changed. When the object is initially created, it will be set to timeCreated.
    public var timeStorageClassUpdated: Date?
    /// Content-Length of the data in bytes.
    public var size: String?
    /// MD5 hash of the data; encoded using base64.
    public var md5Hash: String?
    /// Media download link.
    public var mediaLink: String?
    /// Content-Encoding of the object data.
    public var contentEncoding: String?
    /// Content-Disposition of the object data.
    public var contentDisposition: String?
    /// Content-Language of the object data.
    public var contentLanguage: String?
    /// Cache-Control directive for the object data. If omitted, and the object is accessible to all anonymous users, the default will be public, max-age=3600.
    public var cacheControl: String?
    /// User-provided metadata, in key/value pairs.
    public var metadata: [String: String]?
    /// Access controls on the object, containing one or more objectAccessControls
    public var acl: [ObjectAccessControls]?
    /// The owner of the object. This will always be the uploader of the object.
    public var owner: Owner?
    /// CRC32c checksum, as described in RFC 4960, Appendix B; encoded using base64 in big-endian byte order.
    public var crc32c: String?
    /// Number of underlying components that make up this object. Components are accumulated by compose operations and are limited to a count of 1024, counting 1 for each non-composite component object and componentCount for each composite component object. Note: componentCount is included in the metadata for composite objects only.
    public var componentCount: String?
    /// HTTP 1.1 Entity tag for the object.
    public var etag: String?
    /// Metadata of customer-supplied encryption key, if the object is encrypted by such a key.
    public var customerEncryption: CustomerEncryption?
    /// Cloud KMS Key used to encrypt this object, if the object is encrypted by such a key.
    public var kmsKeyName: String?
    
    public init(kind: String? = nil,
                id: String? = nil,
                selfLink: String? = nil,
                name: String? = nil,
                bucket: String? = nil,
                generation: String? = nil,
                metageneration: String? = nil,
                contentType: String? = nil,
                timeCreated: Date? = nil,
                updated: Date? = nil,
                timeDeleted: Date? = nil,
                storageClass: String? = nil,
                timeStorageClassUpdated: Date? = nil,
                size: String? = nil,
                md5Hash: String? = nil,
                mediaLink: String? = nil,
                contentEncoding: String? = nil,
                contentDisposition: String? = nil,
                contentLanguage: String? = nil,
                cacheControl: String? = nil,
                metadata: [String: String]? = nil,
                acl: [ObjectAccessControls]? = nil,
                owner: Owner? = nil,
                crc32c: String? = nil,
                componentCount: String? = nil,
                etag: String? = nil,
                customerEncryption: CustomerEncryption? = nil,
                kmsKeyName: String? = nil) {
        self.kind = kind
        self.id = id
        self.selfLink = selfLink
        self.name = name
        self.bucket = bucket
        self.generation = generation
        self.metageneration = metageneration
        self.contentType = contentType
        self.timeCreated = timeCreated
        self.updated = updated
        self.timeDeleted = timeDeleted
        self.storageClass = storageClass
        self.timeStorageClassUpdated = timeStorageClassUpdated
        self.size = size
        self.md5Hash = md5Hash
        self.mediaLink = mediaLink
        self.contentEncoding = contentEncoding
        self.contentDisposition = contentDisposition
        self.contentLanguage = contentLanguage
        self.cacheControl = cacheControl
        self.metadata = metadata
        self.acl = acl
        self.owner = owner
        self.crc32c = crc32c
        self.componentCount = componentCount
        self.etag = etag
        self.customerEncryption = customerEncryption
        self.kmsKeyName = kmsKeyName
    }
}

public struct CustomerEncryption: GoogleCloudModel {
    /// The encryption algorithm.
    public var encryptionAlgorithm: String?
    /// SHA256 hash value of the encryption key.
    public var keySha256: String?
    
    public init(encryptionAlgorithm: String? = nil,
                keySha256: String? = nil) {
        self.encryptionAlgorithm = encryptionAlgorithm
        self.keySha256 = keySha256
    }
}

public struct StorageComposeRequest: GoogleCloudModel {
    /// The kind of item this is.
    public var kind: String? = "storage#composeRequest"
    /// The list of source objects that will be concatenated into a single object.
    public var sourceObjects: [StorageSourcObject]?
    /// Properties of the resulting object.
    public var destination: GoogleStorageObject?
    
    public init(kind: String? = nil,
                sourceObjects: [StorageSourcObject]? = nil,
                destination: GoogleStorageObject? = nil) {
        self.kind = kind
        self.sourceObjects = sourceObjects
        self.destination = destination
    }
}

public struct StorageSourcObject: GoogleCloudModel {
    /// The source object's name. The source object's bucket is implicitly the destination bucket.
    public var name: String?
    /// The generation of this object to use as the source.
    public var generation: String?
    /// Conditions that must be met for this operation to execute.
    public var objectPreconditions: StorageObjectPreconditions?
    
    public init(name: String? = nil,
                generation: String? = nil,
                objectPreconditions: StorageObjectPreconditions? = nil) {
        self.name = name
        self.generation = generation
        self.objectPreconditions = objectPreconditions
    }
}

public struct StorageObjectPreconditions: GoogleCloudModel {
    /// Only perform the composition if the generation of the source object that would be used matches this value. If this value and a generation are both specified, they must be the same value or the call will fail.
    public var ifGenerationMatch: String?
    
    public init(ifGenerationMatch: String? = nil) {
        self.ifGenerationMatch = ifGenerationMatch
    }
}
