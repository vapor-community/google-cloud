//
//  StorageRequest.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/19/18.
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
        self.responseDecoder = JSONDecoder()
        self.dateFormatter = DateFormatter()

        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.responseDecoder.dateDecodingStrategy = .formatted(self.dateFormatter)
    }
    
    
    
    func send<GCM: GoogleCloudModel>(method: HTTPMethod,
                                     headers: HTTPHeaders = [:],
                                     path: String,
                                     query: String? = nil,
                                     body: HTTPBody = HTTPBody()) throws -> Future<GCM> {
        return try withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap({ response in
                return try self.responseDecoder.decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
            })
        })
    }

    
    func send(method: HTTPMethod = .GET,
              headers: HTTPHeaders = [:],
              path: String,
              query: String? = nil,
              body: HTTPBody = HTTPBody()) throws -> Future<Data> {
        
        return try withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap({ response in
                return response.http.body.consumeData(on: response)
            })
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

        // perform HTTP request
        return httpClient.send(method, headers: finalHeaders, to: to, beforeSend: { $0.http.body = body }).flatMap({ response in
            guard response.http.status == .ok else {
                print(response)
                return try self.responseDecoder.decode(CloudStorageError.self, from: response.http, maxSize: 65_536, on: self.httpClient.container).map { error in
                    throw error
                    }.catchMap { error -> Response in
                        throw GoogleCloudKMSError.unknownError
                }
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
