//
//  CloudStorageError.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/21/18.
//

import Vapor

public enum CloudStorageError: Error {
    
    public struct CloudStorageErrorBody: Content {
        
    }
    
    case found
    case seeOther
    case notModified
    case temporaryRedirect
    case resumeIncomplete
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case methodNotAllowed
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case requestedRangeNotSatisfiable
}

extension CloudStorageError: Debuggable {
    public var identifier: String {
        return ""
    }
    
    public var reason: String {
        return ""
    }
}
