//
//  Loaders.swift
//  Async
//
//  Created by Brian Hatfield on 7/17/18.
//

import Foundation

enum CredentialLoadError: Error {
    case fileDecodeError
}

extension GoogleApplicationDefaultCredentials {
    init(contentsOfFile path: String) throws {
        let decoder = JSONDecoder()
        let filePath = NSString(string: path).expandingTildeInPath

        if let contents = try String(contentsOfFile: filePath).data(using: .utf8) {
            self = try decoder.decode(GoogleApplicationDefaultCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}

extension GoogleServiceAccountCredentials {
    init(contentsOfFile path: String) throws {
        let decoder = JSONDecoder()
        let filePath = NSString(string: path).expandingTildeInPath

        if let contents = try String(contentsOfFile: filePath).data(using: .utf8) {
            self = try decoder.decode(GoogleServiceAccountCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}
