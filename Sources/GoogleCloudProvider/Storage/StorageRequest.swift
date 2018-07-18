//
//  StorageRequest.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/19/18.
//

import Vapor

extension HTTPHeaders {
    public static var gcsDefault: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        headers.replaceOrAdd(name: .contentType, value: MediaType.json.description)
        return headers
    }
}


public class GoogleCloudStorageRequest {
    var authtoken: OAuthAccessToken?
    var tokenCreatedTime: Date?
    let oauthRequester: GoogleServiceAccountOAuth
    let project: String
    let httpClient: Client
    
    init(httpClient: Client, oauth: GoogleServiceAccountOAuth, project: String) {
        oauthRequester = oauth
        self.httpClient = httpClient
        self.project = project
    }
    
    func send<GCM: GoogleCloudModel>(method: HTTPMethod, headers: HTTPHeaders = [:], path: String, query: String, body: HTTPBody = HTTPBody()) throws -> Future<GCM> {
        // if oauth token is not expired continue as normal
        if let oauth = authtoken, let createdTime = tokenCreatedTime, Int(Date().timeIntervalSince1970) < Int(createdTime.timeIntervalSince1970) + oauth.expiresIn {
            return try _send(method: method, headers: headers, path: path, query: query, body: body, accessToken: oauth.accessToken)
        }
        else {
            return try oauthRequester.requestOauthToken().flatMap({ (oauth) in
                self.authtoken = oauth
                self.tokenCreatedTime = Date()
                return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: oauth.accessToken)
            })
        }
    }
    
    private func _send<GCM: GoogleCloudModel>(method: HTTPMethod, headers: HTTPHeaders, path: String, query: String, body: HTTPBody, accessToken: String) throws -> Future<GCM> {
        var finalHeaders: HTTPHeaders = HTTPHeaders.gcsDefault
        finalHeaders.add(name: .authorization, value: "Bearer \(accessToken)")
        headers.forEach { finalHeaders.replaceOrAdd(name: $0.name, value: $0.value) }
        
        return httpClient.send(method, headers: finalHeaders, to: "\(path)?\(query)", beforeSend: { $0.http.body = body }).flatMap({ (response)  in
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
            guard response.http.status == .ok else {
                return try decoder.decode(CloudStorageError.self, from: response.http, maxSize: 65_536, on: self.httpClient.container).map(to: GCM.self){ error in
                    throw error
                }
            }
            return try decoder.decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
        })
    }
}
