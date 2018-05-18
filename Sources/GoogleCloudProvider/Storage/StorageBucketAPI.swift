//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public class GoogleCloudStorageBucketRequest {
    var authtoken: OAuthResponse?
    var tokenCreatedTime: Date?
    let oauthRequester: GoogleOAuth
    let project: String
    let httpClient: Client
    
    init(httpClient: Client, oauth: GoogleOAuth, project: String) {
        oauthRequester = oauth
        self.httpClient = httpClient
        self.project = project
    }
    
    func send<GCM: GoogleCloudModel>(method: HTTPMethod, path: String, query: String, body: String) throws -> Future<GCM> {
        // if oauth token is not expired continue as normal
        if let oauth = authtoken, let createdTime = tokenCreatedTime, Int(Date().timeIntervalSince1970) < Int(createdTime.timeIntervalSince1970) + oauth.expiresIn {
            return try _send(method: method, path: path, query: query, body: body, accessToken: oauth.accessToken)
        }
        else {
            return try oauthRequester.requestOauthToken().flatMap({ (oauth) in
                self.authtoken = oauth
                self.tokenCreatedTime = Date()
                return try self._send(method: method, path: path, query: query, body: body, accessToken: oauth.accessToken)
            })
        }
    }
    
    private func _send<GCM: GoogleCloudModel>(method: HTTPMethod, path: String, query: String, body: String, accessToken: String) throws -> Future<GCM> {
        return httpClient.send(method, headers: [HTTPHeaderName.authorization.description: "Bearer \(accessToken)"], to: "\(path)?\(query)", beforeSend: { $0.http.body = HTTPBody(string: body) }).flatMap({ (response)  in
            guard response.http.status == .ok else {
                // TODO: Throw proper error
                throw Abort(.internalServerError)
            }
            
            return try JSONDecoder().decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
        })
    }
}

public protocol StorageBucketAPI {
    func delete(bucket: String, queryParameters: [String: String]?) throws -> Future<EmptyStorageBucketResponse>
    func get(bucket: String, queryParameters: [String: String]?) throws -> Future<GoogleStorageBucket>
    func getIAMPolicy(bucket: String, queryParameters: [String: String]?) throws -> Future<IAMPolicy>
//    func create(projectId: String, queryParameters: [String: String]?, name: String, acl: BucketAccessControls?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String: String]?, lifecycle: Lifecycle?, location: String?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
//    func list(for projectName: String, queryParameters: [String: String]?) throws -> Future<GoogleStorageBucketList>
//    func patch(bucket: String, queryParameters: [String: String]?, acl: [BucketAccessControls]?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String: String]?, lifecycle: Lifecycle?, logging: Logging?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
//    func setIAMPolicy(bucket: String, project: String?, iamPolicy: IAMPolicy) throws -> Future<IAMPolicy>
//    func testIAMPermissions(bucket: String, permissions: String, project: String?) throws -> Future<Permission>
//    func update(bucket: String, queryParameters: [String: String]?, acl: [BucketAccessControls], billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String: String]?, lifecycle: Lifecycle?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
}

public class GoogleStorageBucketAPI: StorageBucketAPI {
    let endpoint = "https://www.googleapis.com/storage/v1/b"
    let request: GoogleCloudStorageBucketRequest
    
    init(request: GoogleCloudStorageBucketRequest) {
        self.request = request
    }

    /// Permanently deletes an empty bucket.
    public func delete(bucket: String, queryParameters: [String : String]? = nil) throws -> Future<EmptyStorageBucketResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .DELETE, path: "\(endpoint)/\(bucket)", query: queryParams, body: "")
    }

    /// Returns metadata for the specified bucket.
    public func get(bucket: String, queryParameters: [String : String]? = nil) throws -> Future<GoogleStorageBucket> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)", query: queryParams, body: "")
    }

    /// Returns an IAM policy for the specified bucket.
    public func getIAMPolicy(bucket: String, queryParameters: [String: String]? = nil) throws -> Future<IAMPolicy> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/iam", query: queryParams, body: "")
    }
//
//    /// Creates a new bucket.
//    public func create(projectId: String, queryParameters: [String : String]?, name: String, acl: BucketAccessControls?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String : String]?, lifecycle: Lifecycle?, location: String?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> EventLoopFuture<GoogleStorageBucket> {
//        <#code#>
//    }
//
//    /// Retrieves a list of buckets for a given project.
//    public func list(for projectName: String, queryParameters: [String : String]?) throws -> EventLoopFuture<GoogleStorageBucketList> {
//        <#code#>
//    }
//
//    /// Updates a bucket. Changes to the bucket will be readable immediately after writing, but configuration changes may take time to propagate.
//    public func patch(bucket: String, queryParameters: [String : String]?, acl: [BucketAccessControls]?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String : String]?, lifecycle: Lifecycle?, logging: Logging?, versioning: Versioning?, website: Website?) throws -> EventLoopFuture<GoogleStorageBucket> {
//        <#code#>
//    }
//
//    /// Updates an IAM policy for the specified bucket.
//    public func setIAMPolicy(bucket: String, project: String?, iamPolicy: IAMPolicy) throws -> EventLoopFuture<IAMPolicy> {
//        <#code#>
//    }
//
//    /// Tests a set of permissions on the given bucket to see which, if any, are held by the caller.
//    public func testIAMPermissions(bucket: String, permissions: String, project: String?) throws -> EventLoopFuture<Permission> {
//        <#code#>
//    }
//
//    /// Updates a bucket. Changes to the bucket will be readable immediately after writing, but configuration changes may take time to propagate. This method sets the complete metadata of a bucket. If you want to change some of a bucket's metadata while leaving other parts unaffected, use the PATCH function instead.
//    public func update(bucket: String, queryParameters: [String : String]?, acl: [BucketAccessControls], billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, labels: [String : String]?, lifecycle: Lifecycle?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> EventLoopFuture<GoogleStorageBucket> {
//        <#code#>
//    }
}


