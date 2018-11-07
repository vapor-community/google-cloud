//
//  CloudKMSError.swift
//  GoogleCloudProvider
//
//  Created by Andrei Popa on 11/07/18.
//

import Foundation
import Vapor


public enum CloudKMSError: Error, Debuggable {
    
    case missingEnvironment(variable: String)
    case other(message: String)
    
    public var identifier: String {
        switch self {
        case .missingEnvironment: return "missingEnvironment"
        case .other: return "other"
        }
    }
    
    public var reason: String {
        switch self {
        case let .missingEnvironment(variable):
            return "Missing environment variable '\(variable)'"
        case let .other(message): return message
        }
    }
}


// =========================================================================
// error model
// =========================================================================
struct KMSError: GoogleCloudModel {
    
    var error: KMSErrorBody
    struct KMSErrorBody: Content {
        public var code: Int
        public var message: String
        public var status: String
    }
    
}
