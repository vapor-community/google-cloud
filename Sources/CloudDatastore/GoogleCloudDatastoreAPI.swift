//
//  GoogleCloudDatastoreAPI.swift
//
//
//  Created by Andrew Edwards on 04/10/20.
//

import Vapor
@_exported import Datastore
@_exported import GoogleCloud

extension Application.GoogleCloudPlatform {
    private struct CloudDatastoreAPIKey: StorageKey {
        typealias Value = GoogleCloudDatastoreAPI
    }
    
    private struct CloudDatastoreConfigurationKey: StorageKey {
        typealias Value = GoogleCloudDatastoreConfiguration
    }
    
    private struct CloudDatastoreHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    public var datastore: GoogleCloudDatastoreAPI {
        get {
            if let existing = self.application.storage[CloudDatastoreAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudDatastoreAPIKey.self] = newValue
        }
    }
    
    public struct GoogleCloudDatastoreAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `GoogleCloudDatastore` API.
        public var client: GoogleCloudDatastoreClient {
            do {
                let new = try GoogleCloudDatastoreClient(credentials: self.application.googleCloud.credentials,
                                                         config: self.configuration,
                                                         httpClient: self.http,
                                                         eventLoop: self.eventLoop)
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `GoogleCloudDatastore` APIs.
        public var configuration: GoogleCloudDatastoreConfiguration {
            get {
                if let configuration = application.storage[CloudDatastoreConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud datastore configuration has not been set. Use app.googleCloud.datastore.configuration = ...")
                }
            }
            set {
                if application.storage[CloudDatastoreConfigurationKey.self] == nil {
                    application.storage[CloudDatastoreConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        public var http: HTTPClient {
            if let existing = application.storage[CloudDatastoreHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudDatastoreHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudDatastoreHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudDatastoreHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct GoogleCloudDatastoreKey: StorageKey {
        typealias Value = GoogleCloudDatastoreClient
    }
    
    /// A client used to interact with the `GoogleCloudDatastore` API
    public var gcDatastore: GoogleCloudDatastoreClient {
        if let existing = application.storage[GoogleCloudDatastoreKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.GoogleCloudPlatform.GoogleCloudDatastoreAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[GoogleCloudDatastoreKey.self] = new
            return new
        }
    }
}

