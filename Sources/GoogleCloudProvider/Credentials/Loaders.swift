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
    init(fromFile: String) throws {
        let decoder = JSONDecoder()

        if let contents = try String(contentsOfFile: fromFile).data(using: .utf8) {
            self = try decoder.decode(GoogleApplicationDefaultCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}

extension GoogleServiceAccountCredentials {
    init(fromFile: String) throws {
        let decoder = JSONDecoder()

        if let contents = try String(contentsOfFile: fromFile).data(using: .utf8) {
            self = try decoder.decode(GoogleServiceAccountCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}
