//
//  OAuthResponse.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/15/18.
//

import Vapor

public struct OAuthAccessToken: Content {
    public var accessToken: String
    public var tokenType: String
    public var expiresIn: Int

    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
