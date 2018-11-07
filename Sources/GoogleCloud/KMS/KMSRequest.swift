//
//  KMSRequest.swift
//  GoogleCloudProvider
//
//  Created by Andrei Popa on 11/07/18.
//

import Vapor



public final class GoogleCloudKMSRequest {
    
    let refreshableToken: OAuthRefreshable
    let project: String
    let location: String
    
    let httpClient: Client
    let responseDecoder: JSONDecoder
    let dateFormatter: DateFormatter
    
    var currentToken: OAuthAccessToken?
    var tokenCreatedTime: Date?
    
    
    init(httpClient: Client, oauth: OAuthRefreshable, project: String, location: String) {
        self.refreshableToken = oauth
        self.httpClient = httpClient
        self.project = project
        self.location = location
        
        // decoder
        self.responseDecoder = JSONDecoder()
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.responseDecoder.dateDecodingStrategy = .formatted(self.dateFormatter)
    }
    
    
    /// perform request and return Codable
    func send<Model: Codable>(method: HTTPMethod,
                              headers: HTTPHeaders = [:],
                              path: String,
                              query: String? = nil,
                              body: HTTPBody = HTTPBody(),
                              model: Model.Type) throws -> Future<Model> {
        return try withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap({ response in
                return try self.responseDecoder.decode(Model.self, from: response.http, maxSize: 65_536, on: response)
            })
        })
    }
    
    
    /// perform request and return Data from Body
    func send(method: HTTPMethod = .GET,
              headers: HTTPHeaders = [:],
              path: String,
              query: String? = nil,
              body: HTTPBody = HTTPBody()) throws -> Future<Data> {
        
        return try withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken)
        })
        // return data from body
        .flatMap({ response in
            return response.http.body.consumeData(on: response)
        })
    }
    
    
    
    private func _send(method: HTTPMethod,
                       headers: HTTPHeaders,
                       path: String,
                       query: String? = nil,
                       body: HTTPBody,
                       accessToken: String) throws -> Future<Response> {
        
        // add Bearer token header
        var finalHeaders: HTTPHeaders = HTTPHeaders.gcsDefault
        finalHeaders.add(name: .authorization, value: "Bearer \(accessToken)")
        headers.forEach { finalHeaders.replaceOrAdd(name: $0.name, value: $0.value) }
        
        // if we have a query, append
        var to: String {
            if let query = query {
                return "\(path)?\(query)"
            }
            return path
        }
        
        // performs HTTP request
        return httpClient.send(method, headers: finalHeaders, to: to, beforeSend: { $0.http.body = body })
            .flatMap({ response in
                guard response.http.status == .ok else {
                    // print(response)
                    return try self.responseDecoder
                        .decode(KMSError.self, from: response.http, maxSize: 65_536, on: self.httpClient.container)
                        // we are on the error chain, trigger an error
                        .map { throw CloudKMSError.other(message: $0.error.message) }
                }
                return response.future(response)
            })
    }
    
    
    // =========================================================================
    // to generalize
    // =========================================================================
    
    private func withToken<F>(_ closure: @escaping (OAuthAccessToken) throws -> Future<F>) throws -> Future<F>{
        guard let token = currentToken, let created = tokenCreatedTime, refreshableToken.isFresh(token: token, created: created) else {
            return try refreshableToken.refresh().flatMap({ newToken in
                self.currentToken = newToken
                self.tokenCreatedTime = Date()
                
                return try closure(newToken)
            })
        }
        
        return try closure(token)
    }
    
}
