//
//  GoogleCloudStorageAPI.swift
//  
//
//  Created by Andrew Edwards on 11/2/19.
//

import Vapor

@_exported import GoogleCloud
@_exported import Storage

extension Application.GoogleCloudPlatform {
    private struct CloudStorageAPIKey: StorageKey {
        typealias Value = GoogleCloudStorageAPI
    }
    
    private struct CloudStorageConfigurationKey: StorageKey {
        typealias Value = GoogleCloudStorageConfiguration
    }
    
    private struct CloudStorageHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    public var storage: GoogleCloudStorageAPI {
        get {
            if let existing = self.application.storage[CloudStorageAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudStorageAPIKey.self] = newValue
        }
    }
    
    public struct GoogleCloudStorageAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `GoogleCloudStorage` API.
        public var client: GoogleCloudStorageClient {
            do {
                let new = try GoogleCloudStorageClient(credentials: self.application.googleCloud.credentials,
                                                       storageConfig: self.configuration,
                                                       httpClient: self.http,
                                                       eventLoop: self.eventLoop)
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `GoogleCloudStorage` APIs.
        public var configuration: GoogleCloudStorageConfiguration {
            get {
                if let configuration = application.storage[CloudStorageConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud storage configuration has not been set. Use app.googleCloud.storage.configuration = ...")
                }
            }
            set {
                if application.storage[CloudStorageConfigurationKey.self] == nil {
                    application.storage[CloudStorageConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        public var http: HTTPClient {
            if let existing = application.storage[CloudStorageHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudStorageHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudStorageHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudStorageHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct GoogleCloudStorageKey: StorageKey {
        typealias Value = GoogleCloudStorageClient
    }
    
    /// A client used to interact with the `GoogleCloudStorage` API
    public var gcs: GoogleCloudStorageClient {
        if let existing = application.storage[GoogleCloudStorageKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.GoogleCloudPlatform.GoogleCloudStorageAPI(application: self.application, eventLoop: self.eventLoop).client
            pplication.storage[GoogleCloudStorageKey.self] = new
            return new
        }
    }
}
