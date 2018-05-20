//
//  BucketAccessControlAPI.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/19/18.
//

import Vapor

public protocol BucketAccessControlAPI {
    func delete(bucket: String, entity: String, queryParameters: [String: String]?) throws -> Future<EmptyResponse>
    func get(bucket: String, entity: String, queryParameters: [String: String]?) throws -> Future<BucketAccessControls>
    func create(bucket: String, entity: String, role: String, queryParameters: [String: String]?) throws -> Future<BucketAccessControls>
    func list(bucket: String, queryParameters: [String: String]?) throws -> Future<BucketAccessControlList>
    func patch(bucket: String, entity: String, queryParameters: [String: String]?) throws -> Future<BucketAccessControls>
    func update(bucket: String, entity: String, role: String?, queryParameters: [String: String]?) throws -> Future<BucketAccessControls>
}

public class GoogleBucketAccessControlAPI: BucketAccessControlAPI {
    let endpoint = "https://www.googleapis.com/storage/v1/b"
    let request: GoogleCloudStorageRequest
    
    init(request: GoogleCloudStorageRequest) {
        self.request = request
    }
    
    /// Permanently deletes the ACL entry for the specified entity on the specified bucket.
    public func delete(bucket: String, entity: String, queryParameters: [String: String]? = nil) throws -> Future<EmptyResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .DELETE, path: "\(endpoint)/\(bucket)/acl/\(entity)", query: queryParams, body: "")
    }
    
    /// Returns the ACL entry for the specified entity on the specified bucket.
    public func get(bucket: String, entity: String, queryParameters: [String: String]? = nil) throws -> Future<BucketAccessControls> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/acl/\(entity)", query: queryParams, body: "")
    }
    
    /// Creates a new ACL entry on the specified bucket.
    public func create(bucket: String, entity: String, role: String, queryParameters: [String: String]? = nil) throws -> Future<BucketAccessControls> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let body = try JSONEncoder().encode(["entity": entity, "role": role]).convert(to: String.self)
        
        return try request.send(method: .POST, path: "\(endpoint)/\(bucket)/acl", query: queryParams, body: body)
    }
    
    /// Retrieves ACL entries on a specified bucket.
    public func list(bucket: String, queryParameters: [String : String]?) throws -> Future<BucketAccessControlList> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/acl", query: queryParams, body: "")
    }
    
    /// Updates an ACL entry on the specified bucket. This method supports patch semantics.
    public func patch(bucket: String, entity: String, queryParameters: [String: String]? = nil) throws -> Future<BucketAccessControls> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .PATCH, path: "\(endpoint)/\(bucket)/acl/\(entity)", query: queryParams, body: "")
    }
    
    /// Updates an ACL entry on the specified bucket.
    public func update(bucket: String,
                       entity: String,
                       role: String? = nil,
                       queryParameters: [String: String]? = nil) throws -> Future<BucketAccessControls> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        var body = ""
        
        if let role = role {
            body = try JSONEncoder().encode(["role": role]).convert(to: String.self)
        }
        
        return try request.send(method: .POST, path: "\(endpoint)/\(bucket)/acl/\(entity)", query: queryParams, body: body)
    }
}
