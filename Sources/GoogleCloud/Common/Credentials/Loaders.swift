//
//  Loaders.swift
//  Async
//
//  Created by Brian Hatfield on 7/17/18.
//

import Foundation

enum CredentialLoadError: GoogleCloudError {
    
    var localizedDescription: String {
        switch self {
        case .fileLoadError(let path):
            return "Failed to load GoogleCloud credentials from the file path \(path)"
        }
    }
    var identifier: String {
        switch self {
        case .fileLoadError(_):
            return "file-load-error"
        }
    }
    
    var reason: String { return localizedDescription }
    
    case fileLoadError(String)
}

extension GoogleApplicationDefaultCredentials {
    init(contentsOfFile path: String) throws {
        let decoder = JSONDecoder()
        let filePath = NSString(string: path).expandingTildeInPath

        if let contents = try String(contentsOfFile: filePath).data(using: .utf8) {
            self = try decoder.decode(GoogleApplicationDefaultCredentials.self, from: contents)
        } else {
            throw CredentialLoadError.fileLoadError(path)
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
            throw CredentialLoadError.fileLoadError(path)
        }
    }
}
