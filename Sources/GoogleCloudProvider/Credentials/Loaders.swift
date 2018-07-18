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

extension ApplicationDefaultCredentials {
    init(fromFile: String) throws {
        let decoder = JSONDecoder()

        if let contents = try String(contentsOfFile: fromFile).data(using: .utf8) {
            self = try decoder.decode(ApplicationDefaultCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}

extension ServiceAccountCredentials {
    init(fromFile: String) throws {
        let decoder = JSONDecoder()

        if let contents = try String(contentsOfFile: fromFile).data(using: .utf8) {
            self = try decoder.decode(ServiceAccountCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileDecodeError
        }
    }
}
