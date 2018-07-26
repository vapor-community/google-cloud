//
//  ApplicationDefault.swift
//  Async
//
//  Created by Brian Hatfield on 7/17/18.
//

import Foundation

// Loads credentials from ~/.config/gcloud/application_default_credentials.json
//
// Example JSON:
//    {
//        "client_id": "IDSTRING.apps.googleusercontent.com",
//        "client_secret": "SECRETSTRING",
//        "refresh_token": "REFRESHTOKEN",
//        "type": "authorized_user"
//    }

public struct GoogleApplicationDefaultCredentials: Codable {
    public let clientId: String
    public let clientSecret: String
    public let refreshToken: String
    public let type: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case refreshToken = "refresh_token"
        case type
    }
}
