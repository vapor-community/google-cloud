//
//  KMSAPI.swift
//  GoogleCloudProvider
//
//  Created by Andrei Popa on 11/07/18.
//

import Vapor



public final class GoogleKMSAPI {
    
    let endpoint: String
    let request: GoogleCloudKMSRequest
    
    
    init(request: GoogleCloudKMSRequest) {
        self.request = request
        /// Cloud KMS endpoints are bound to location & project ID∫
        self.endpoint = "https://cloudkms.googleapis.com/v1/projects/\(request.project)/locations/\(request.location)"
    }
    
    
    /// decrypts ciphertext
    public func decrypt(keyRing: String, keyName: String, ciphertext: String) throws -> Future<String> {
        
        struct KMSDecryptResponse: Codable {
            let plaintext: String
        }
        
        let googleKMSURI = "\(endpoint)/keyRings/\(keyRing)/cryptoKeys/\(keyName):decrypt"
        
        let body = HTTPBody(string: """
            { "ciphertext": "\(ciphertext)"}
            """)
        
        /// return only the plaintext
        return try request.send(method: .POST, path: googleKMSURI, body: body, model: KMSDecryptResponse.self).map({ $0.plaintext })
    }
    
    

    
}
