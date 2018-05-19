//
//  StorageRequest.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/19/18.
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
            
            return try decoder.decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
        })
    }
}
