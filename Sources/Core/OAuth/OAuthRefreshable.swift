//
//  OAuthRefreshable.swift
//  GoogleCloudProvider
//
//  Created by Brian Hatfield on 7/17/18.
//

import Vapor

// Constants for OAuth URLs. PascalCase style from this suggestion: https://stackoverflow.com/a/31893982
let GoogleOAuthTokenUrl = "https://www.googleapis.com/oauth2/v4/token"
let GoogleOAuthTokenAudience = GoogleOAuthTokenUrl

public protocol OAuthRefreshable {
    func isFresh() -> Bool
    func refresh() throws -> Future<OAuthAccessToken>
    func withToken<F>(_ closure: @escaping (OAuthAccessToken) throws -> Future<F>) throws -> Future<F>

    var currentToken: OAuthAccessToken? { get set }
    var currentTokenCreated: Date? { get set }
}

extension OAuthRefreshable {
    public func isFresh() -> Bool {
        let now = Date()

        if let token = currentToken, let created = currentTokenCreated {
            let expiration = created.addingTimeInterval(TimeInterval(token.expiresIn))

            return expiration > now
        }

        return false
    }
}
