//
//  OAuthRefreshRequest.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/15/18.
//

import Vapor
import Crypto
import JWT

public protocol OAuthRefreshRequest {
    func requestOauthToken() throws -> Future<OAuthResponse>
    func generateJWT() throws -> String
}

public class GoogleOAuth: OAuthRefreshRequest {
    let email: String
    let scope: String
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let rsaPrivateKey: String
    let client: Client
    
    init(serviceEmail: String, scopes: [String], privateKey: String, httpClient: Client) {
        email = serviceEmail
        scope = scopes.joined(separator: " ")
        rsaPrivateKey = privateKey
        client = httpClient
    }

    public func requestOauthToken() throws -> Future<OAuthResponse> {
        let headers: HTTPHeaders = ["Content-Type": MediaType.urlEncodedForm.description]
        let token = try generateJWT()
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(token)"

        return client.post(audience, headers: headers, beforeSend: { $0.http.body = HTTPBody(string: body) }).flatMap(to: OAuthResponse.self) { (response) in
                if response.http.status == .ok {
                    return try JSONDecoder().decode(OAuthResponse.self, from: response.http, maxSize: 65_536, on: response)
                }
                throw Abort(.internalServerError)
            }
    }

    public func generateJWT() throws -> String {
        let payload = OAuthPayload(iss: IssuerClaim(value: email),
                                   scope: scope,
                                   aud: AudienceClaim(value: audience),
                                   iat: IssuedAtClaim(value: Date()),
                                   exp: ExpirationClaim(value: Date().addingTimeInterval(3600)))

        let pk = try RSAKey.private(pem: rsaPrivateKey)
        let signer = JWTSigner.rs256(key: pk)
        var jwt = JWT<OAuthPayload>(payload: payload)
        let jwtData = try jwt.sign(using: signer)
        return String(data: jwtData, encoding: .utf8)!
    }
}
