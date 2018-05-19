//
//  StorageBucket.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

public class GoogleCloudStorageRequest {
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
        return httpClient.send(method, headers: [HTTPHeaderName.authorization.description: "Bearer \(accessToken)", HTTPHeaderName.contentType.description: MediaType.json.description], to: "\(path)?\(query)", beforeSend: { $0.http.body = HTTPBody(string: body) }).flatMap({ (response)  in
            guard response.http.status == .ok else {
                // TODO: Throw proper error
                throw Abort(.internalServerError)
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            return try JSONDecoder().decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
        })
    }
}

public protocol StorageBucketAPI {
    func delete(bucket: String, queryParameters: [String: String]?) throws -> Future<EmptyStorageBucketResponse>
    func get(bucket: String, queryParameters: [String: String]?) throws -> Future<GoogleStorageBucket>
    func getIAMPolicy(bucket: String, queryParameters: [String: String]?) throws -> Future<IAMPolicy>
    func create(queryParameters: [String: String]?, name: String, acl: [BucketAccessControls]?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, encryption: Encryption?, labels: [String: String]?, lifecycle: Lifecycle?, location: String?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
    func list(queryParameters: [String: String]?) throws -> Future<GoogleStorageBucketList>
    func patch(bucket: String, queryParameters: [String: String]?, acl: [BucketAccessControls]?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, encryption: Encryption?, labels: [String: String]?, lifecycle: Lifecycle?, logging: Logging?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
    func setIAMPolicy(bucket: String, iamPolicy: IAMPolicy, queryParameters: [String : String]?) throws -> Future<IAMPolicy>
    func testIAMPermissions(bucket: String, permissions: [String], queryParameters: [String : String]?) throws -> Future<Permission>
    func update(bucket: String, acl: [BucketAccessControls], queryParameters: [String: String]?, billing: Billing?, cors: [Cors]?, defaultObjectAcl: [DefaultObjectACL]?, encryption: Encryption?, labels: [String: String]?, lifecycle: Lifecycle?, logging: Logging?, storageClass: StorageClass?, versioning: Versioning?, website: Website?) throws -> Future<GoogleStorageBucket>
}

public class GoogleStorageBucketAPI: StorageBucketAPI {
    let endpoint = "https://www.googleapis.com/storage/v1/b"
    let request: GoogleCloudStorageRequest
    
    init(request: GoogleCloudStorageRequest) {
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

    /// Creates a new bucket.
    public func create( queryParameters: [String : String]? = nil,
                        name: String,
                        acl: [BucketAccessControls]? = nil,
                        billing: Billing? = nil,
                        cors: [Cors]? = nil,
                        defaultObjectAcl: [DefaultObjectACL]? = nil,
                        encryption: Encryption? = nil,
                        labels: [String : String]? = nil,
                        lifecycle: Lifecycle? = nil,
                        location: String? = nil,
                        logging: Logging? = nil,
                        storageClass: StorageClass? = nil,
                        versioning: Versioning? = nil,
                        website: Website? = nil) throws -> Future<GoogleStorageBucket> {
        var body: [String: Any] = ["name": name]
        var query = ""
        
        if var queryParameters = queryParameters {
            queryParameters["project"] = request.project
            query = queryParameters.queryParameters
        }
        else {
            query = "project=\(request.project)"
        }
        
        if let acl = acl {
            body["acl"] = try acl.map { try $0.toEncodedDictionary() }
        }
        
        if let billing = billing {
            body["billing"] = try billing.toEncodedDictionary()
        }
        
        if let cors = cors {
            body["cors"] = try cors.map { try $0.toEncodedDictionary() }
        }
        
        if let defaultObjectAcl = defaultObjectAcl {
            body["defaultObjectAcl"] = try defaultObjectAcl.map { try $0.toEncodedDictionary() }
        }
        
        if let encryption = encryption {
            body["encryption"] = try encryption.toEncodedDictionary()
        }
        
        if let labels = labels {
            body["labels"] = labels
        }
        
        if let lifecycle = lifecycle {
            body["lifecycle"] = try lifecycle.toEncodedDictionary()
        }
        
        if let location = location {
            body["location"] = location
        }
        
        if let logging = logging {
            body["logging"] = try logging.toEncodedDictionary()
        }
        
        if let storageClass = storageClass {
            body["storageClass"] = storageClass.rawValue
        }
        
        if let versioning = versioning {
            body["versioning"] = try versioning.toEncodedDictionary()
        }
        
        if let website = website {
            body["website"] = try website.toEncodedDictionary()
        }
        
        let requestBody = try JSONSerialization.data(withJSONObject: body).convert(to: String.self)
        
        return try request.send(method: .POST, path: endpoint, query: query, body: requestBody)
    }

    /// Retrieves a list of buckets for a given project.
    public func list(queryParameters: [String : String]? = nil) throws -> Future<GoogleStorageBucketList> {
        var query = ""
        
        if var queryParameters = queryParameters {
            queryParameters["project"] = request.project
            query = queryParameters.queryParameters
        }
        else {
            query = "project=\(request.project)"
        }
        
        return try request.send(method: .GET, path: endpoint, query: query, body: "")
    }

    /// Updates a bucket. Changes to the bucket will be readable immediately after writing, but configuration changes may take time to propagate.
    public func patch(bucket: String,
                      queryParameters: [String : String]? = nil,
                      acl: [BucketAccessControls]? = nil,
                      billing: Billing? = nil,
                      cors: [Cors]? = nil,
                      defaultObjectAcl: [DefaultObjectACL]? = nil,
                      encryption: Encryption? = nil,
                      labels: [String : String]? = nil,
                      lifecycle: Lifecycle? = nil,
                      logging: Logging? = nil,
                      versioning: Versioning? = nil,
                      website: Website? = nil) throws -> Future<GoogleStorageBucket> {
        var body: [String: Any] = [:]
        var query = ""
        
        if let queryParameters = queryParameters {
            query = queryParameters.queryParameters
        }
        
        if let acl = acl {
            body["acl"] = try acl.map { try $0.toEncodedDictionary() }
        }
        
        if let billing = billing {
            body["billing"] = try billing.toEncodedDictionary()
        }
        
        if let cors = cors {
            body["cors"] = try cors.map { try $0.toEncodedDictionary() }
        }
        
        if let defaultObjectAcl = defaultObjectAcl {
            body["defaultObjectAcl"] = try defaultObjectAcl.map { try $0.toEncodedDictionary() }
        }
        
        if let encryption = encryption {
            body["encryption"] = try encryption.toEncodedDictionary()
        }
        
        if let labels = labels {
            body["labels"] = labels
        }
        
        if let lifecycle = lifecycle {
            body["lifecycle"] = try lifecycle.toEncodedDictionary()
        }
        
        if let logging = logging {
            body["logging"] = try logging.toEncodedDictionary()
        }
        
        if let versioning = versioning {
            body["versioning"] = try versioning.toEncodedDictionary()
        }
        
        if let website = website {
            body["website"] = try website.toEncodedDictionary()
        }
        
        let requestBody = try JSONSerialization.data(withJSONObject: body).convert(to: String.self)
        
        return try request.send(method: .PATCH, path: endpoint, query: query, body: requestBody)
    }

    /// Updates an IAM policy for the specified bucket.
    public func setIAMPolicy(bucket: String,
                             iamPolicy: IAMPolicy,
                             queryParameters: [String : String]? = nil) throws -> Future<IAMPolicy> {
        var query = ""
        
        if let queryParameters = queryParameters {
            query = queryParameters.queryParameters
        }

        let requestBody = try JSONSerialization.data(withJSONObject: try iamPolicy.toEncodedDictionary()).convert(to: String.self)
        
        return try request.send(method: .PUT, path: "\(endpoint)/\(bucket)/iam", query: query, body: requestBody)
    }

    /// Tests a set of permissions on the given bucket to see which, if any, are held by the caller.
    public func testIAMPermissions(bucket: String,
                                   permissions: [String],
                                   queryParameters: [String : String]? = nil) throws -> Future<Permission> {
        var query = ""
        
        if let queryParameters = queryParameters {
            query = queryParameters.queryParameters
            // if there are any permissions it's safe to add an ampersand to the end of the query we currently have.
            if permissions.count > 0 {
                query.append("&")
            }
        }
        
        let perms = permissions.map({ "permissions=\($0)" }).joined(separator: "&")
        
        query.append(perms)
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/iam/testPermissions", query: query, body: "")
    }

    /// Updates a bucket. Changes to the bucket will be readable immediately after writing, but configuration changes may take time to propagate. This method sets the complete metadata of a bucket. If you want to change some of a bucket's metadata while leaving other parts unaffected, use the PATCH function instead.
    public func update(bucket: String,
                       acl: [BucketAccessControls],
                       queryParameters: [String : String]? = nil,
                       billing: Billing? = nil,
                       cors: [Cors]? = nil,
                       defaultObjectAcl: [DefaultObjectACL]? = nil,
                       encryption: Encryption? = nil,
                       labels: [String : String]? = nil,
                       lifecycle: Lifecycle? = nil,
                       logging: Logging? = nil,
                       storageClass: StorageClass? = nil,
                       versioning: Versioning? = nil,
                       website: Website? = nil) throws -> Future<GoogleStorageBucket> {
        var body: [String: Any] = [:]
        var query = ""
        
        body["acl"] = try acl.map { try $0.toEncodedDictionary() }
        
        if let queryParameters = queryParameters {
            query = queryParameters.queryParameters
        }
        
        
        if let billing = billing {
            body["billing"] = try billing.toEncodedDictionary()
        }
        
        if let cors = cors {
            body["cors"] = try cors.map { try $0.toEncodedDictionary() }
        }
        
        if let defaultObjectAcl = defaultObjectAcl {
            body["defaultObjectAcl"] = try defaultObjectAcl.map { try $0.toEncodedDictionary() }
        }
        
        if let encryption = encryption {
            body["encryption"] = try encryption.toEncodedDictionary()
        }
        
        if let labels = labels {
            body["labels"] = labels
        }
        
        if let lifecycle = lifecycle {
            body["lifecycle"] = try lifecycle.toEncodedDictionary()
        }
        
        if let logging = logging {
            body["logging"] = try logging.toEncodedDictionary()
        }
        
        if let storageClass = storageClass {
            body["storageClass"] = storageClass.rawValue
        }
        
        if let versioning = versioning {
            body["versioning"] = try versioning.toEncodedDictionary()
        }
        
        if let website = website {
            body["website"] = try website.toEncodedDictionary()
        }
        
        let requestBody = try JSONSerialization.data(withJSONObject: body).convert(to: String.self)
        
        return try request.send(method: .PUT, path: "\(endpoint)/\(bucket)", query: query, body: requestBody)
    }
}
