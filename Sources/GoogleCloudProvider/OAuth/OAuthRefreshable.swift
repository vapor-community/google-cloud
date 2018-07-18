//
//  OAuthRefreshable.swift
//  GoogleCloudProvider
//
//  Created by Brian Hatfield on 7/17/18.
//

import Vapor

public protocol OAuthRefreshable {
    func isFresh(token: OAuthAccessToken, created: Date) -> Bool
    func refresh() throws -> Future<OAuthAccessToken>
}

extension OAuthRefreshable {
    public func isFresh(token: OAuthAccessToken, created: Date) -> Bool {
        let now = Date()
        let expiration = Date().addingTimeInterval(TimeInterval(token.expiresIn))

        return expiration > now
    }
}
