//
//  GoogleCloudPubSubAPI.swift
//  
//
//  Created by Susheel Athmakuri on 6/20/21.
//

import Vapor
@_exported import PubSub
@_exported import GoogleCloud

extension Application.GoogleCloudPlatform {
    private struct CloudPubSubAPIKey: StorageKey {
        typealias Value = GoogleCloudPubSubAPI
    }
    
    private struct CloudPubSubConfigurationKey: StorageKey {
        typealias Value = GoogleCloudPubSubConfiguration
    }
    
    private struct CloudSPubSubHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    public var pubsub: GoogleCloudPubSubAPI {
        get {
            if let existing = self.application.storage[CloudPubSubAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application,
                             eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudPubSubAPIKey.self] = newValue
        }
    }
    
    public struct GoogleCloudPubSubAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `GoogleCloudPubSub` API.
        public var client: GoogleCloudPubSubClient {
            do {
                let new = try GoogleCloudPubSubClient(credentials: self.application.googleCloud.credentials, config: self.configuration, httpClient: self.http, eventLoop: self.eventLoop)
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `GoogleCloudPubSub` APIs.
        public var configuration: GoogleCloudPubSubConfiguration {
            get {
                if let configuration = application.storage[CloudPubSubConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud PubSub configuration has not been set. Use app.googleCloud.pubsub.configuration = ...")
                }
            }
            set {
                if application.storage[CloudPubSubConfigurationKey.self] == nil {
                    application.storage[CloudPubSubConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        public var http: HTTPClient {
            if let existing = application.storage[CloudSPubSubHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudSPubSubHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudSPubSubHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudSPubSubHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct GoogleCloudPubSubKey: StorageKey {
        typealias Value = GoogleCloudPubSubClient
    }
    
    /// A client used to interact with the `GoogleCloudPubSub` API
    public var gcPubSub: GoogleCloudPubSubClient {
        if let existing = application.storage[GoogleCloudPubSubKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.GoogleCloudPlatform.GoogleCloudPubSubAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[GoogleCloudPubSubKey.self] = new
            return new
        }
    }
}
