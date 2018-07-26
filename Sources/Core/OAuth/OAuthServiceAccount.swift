//
//  OAuthServiceAccount.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/15/18.
//

import Vapor
import Crypto
import JWT

public class OAuthServiceAccount: OAuthRefreshable {
    let client: Client
    let credentials: GoogleServiceAccountCredentials

    public var currentToken: OAuthAccessToken?
    public var currentTokenCreated: Date?

    let scope: String

    init(credentials: GoogleServiceAccountCredentials, scopes: [String], httpClient: Client) {
        self.credentials = credentials
        self.scope = scopes.joined(separator: " ")
        self.client = httpClient
    }

    // Google Documentation for this approach: https://developers.google.com/identity/protocols/OAuth2ServiceAccount
    public func refresh() throws -> Future<OAuthAccessToken> {
        let headers: HTTPHeaders = ["Content-Type": MediaType.urlEncodedForm.description]
        let token = try generateJWT()

        let encoder = URLEncodedFormEncoder()

        let bodyParts = [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": token
        ]

        let body = try encoder.encode(bodyParts)

        return client.post(GoogleOAuthTokenUrl, headers: headers, beforeSend: { $0.http.body = HTTPBody(data: body) }).flatMap(to: OAuthAccessToken.self) { (response) in
                if response.http.status == .ok {
                    return try JSONDecoder().decode(OAuthAccessToken.self, from: response.http, maxSize: 65_536, on: response)
                }
                throw Abort(.internalServerError)
            }
    }

    public func generateJWT() throws -> String {
        let payload = OAuthPayload(iss: IssuerClaim(value: credentials.clientEmail),
                                   scope: scope,
                                   aud: AudienceClaim(value: GoogleOAuthTokenAudience),
                                   iat: IssuedAtClaim(value: Date()),
                                   exp: ExpirationClaim(value: Date().addingTimeInterval(3600)))

        let pk = try RSAKey.private(pem: credentials.privateKey)
        let signer = JWTSigner.rs256(key: pk)
        var jwt = JWT<OAuthPayload>(payload: payload)
        let jwtData = try jwt.sign(using: signer)
        return String(data: jwtData, encoding: .utf8)!
    }

    public func withToken<F>(_ closure: @escaping (OAuthAccessToken) throws -> Future<F>) throws -> Future<F> {
        guard let token = currentToken, self.isFresh() else {
            return try self.refresh().flatMap({ newToken in
                self.currentToken = newToken
                self.currentTokenCreated = Date()

                return try closure(newToken)
            })
        }

        return try closure(token)
    }
}
