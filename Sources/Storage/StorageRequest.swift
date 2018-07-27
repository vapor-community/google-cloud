//
//  StorageRequest.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 5/19/18.
//

import Vapor
import GoogleCloudCore

extension HTTPHeaders {
    public static var gcsDefault: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        headers.replaceOrAdd(name: .contentType, value: MediaType.json.description)
        return headers
    }
}


public final class GoogleCloudStorageRequest {
    let refreshableToken: OAuthRefreshable
    let project: String

    let httpClient: Client
    let responseDecoder: JSONDecoder
    let dateFormatter: DateFormatter

    init(httpClient: Client, oauth: OAuthRefreshable, project: String) {
        self.refreshableToken = oauth
        self.httpClient = httpClient
        self.project = project
        self.responseDecoder = JSONDecoder()
        self.dateFormatter = DateFormatter()

        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.responseDecoder.dateDecodingStrategy = .formatted(self.dateFormatter)
    }

    func send<GCM: GoogleCloudModel>(method: HTTPMethod, headers: HTTPHeaders = [:], path: String, query: String, body: HTTPBody = HTTPBody()) throws -> Future<GCM> {
        return try refreshableToken.withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap({ response in
                return try self.responseDecoder.decode(GCM.self, from: response.http, maxSize: 65_536, on: response)
            })
        })
    }

    func send(method: HTTPMethod = .GET, headers: HTTPHeaders = [:], path: String, query: String, body: HTTPBody = HTTPBody()) throws -> Future<Data> {
        return try refreshableToken.withToken({ token in
            return try self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap({ response in
                return response.http.body.consumeData(on: response)
            })
        })
    }

    private func _send(method: HTTPMethod, headers: HTTPHeaders, path: String, query: String, body: HTTPBody, accessToken: String) throws -> Future<Response> {
        var finalHeaders: HTTPHeaders = HTTPHeaders.gcsDefault
        finalHeaders.add(name: .authorization, value: "Bearer \(accessToken)")
        headers.forEach { finalHeaders.replaceOrAdd(name: $0.name, value: $0.value) }

        return httpClient.send(method, headers: finalHeaders, to: "\(path)?\(query)", beforeSend: { $0.http.body = body }).flatMap({ response in
            guard response.http.status == .ok else {
                _ = try self.responseDecoder.decode(CloudStorageError.self, from: response.http, maxSize: 65_536, on: self.httpClient.container).map { error in
                    throw error
                }

                throw GoogleCloudError.unknownError
            }

            return response.future(response)
        })
    }
}
