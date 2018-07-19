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
    let refreshableToken: OAuthRefreshable
    let httpClient: Client
    let project: String

    var currentToken: OAuthAccessToken?
    var tokenCreatedTime: Date?
    
    init(httpClient: Client, oauth: OAuthRefreshable, project: String) {
        self.refreshableToken = oauth
        self.httpClient = httpClient
        self.project = project
    }
    
    func send<GCM: GoogleCloudModel>(method: HTTPMethod, headers: HTTPHeaders = [:], path: String, query: String, body: HTTPBody = HTTPBody()) throws -> Future<GCM> {
        // if oauth token is not expired continue as normal

        if let token = currentToken, let created = tokenCreatedTime, refreshableToken.isFresh(token: token, created: created) {
            return try _send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken)
        } else {
            return try refreshableToken.refresh().flatMap({ (newToken) in
                self.currentToken = newToken
                self.tokenCreatedTime = Date()
                return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: newToken.accessToken)
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
