//
//  GoogleCloudTranslationAPI.swift
//  
//
//  Created by Andrew Edwards on 5/4/21.
//

import Vapor
@_exported import Translation
@_exported import GoogleCloud

extension Application.GoogleCloudPlatform {
    
    private struct CloudTranslationAPIKey: StorageKey {
        typealias Value = GoogleCloudTranslationAPI
    }
    
    private struct CloudSecretManagerConfigurationKey: StorageKey {
        typealias Value = GoogleCloudTranslationConfiguration
    }
    
    private struct CloudTranslationHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    public var translation: GoogleCloudTranslationAPI {
        get {
            if let existing = self.application.storage[CloudTranslationAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudTranslationAPIKey.self] = newValue
        }
    }
    
    public struct GoogleCloudTranslationAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `GoogleCloudTranslation` API.
        public var client: GoogleCloudTranslationClient {
            do {
                let new = try GoogleCloudTranslationClient(credentials: self.application.googleCloud.credentials,
                                                           config: self.configuration,
                                                           httpClient: self.http,
                                                           eventLoop: self.eventLoop)
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `GoogleCloudTranslation` APIs.
        public var configuration: GoogleCloudTranslationConfiguration {
            get {
                if let configuration = application.storage[CloudSecretManagerConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud Translation configuration has not been set. Use app.googleCloud.translation.configuration = ...")
                }
            }
            set {
                if application.storage[CloudSecretManagerConfigurationKey.self] == nil {
                    application.storage[CloudSecretManagerConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        public var http: HTTPClient {
            if let existing = application.storage[CloudTranslationHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudTranslationHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudTranslationHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudTranslationHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct GoogleCloudTranslationKey: StorageKey {
        typealias Value = GoogleCloudTranslationClient
    }
    
    /// A client used to interact with the `GoogleCloudTranslation` API
    public var gcTranslation: GoogleCloudTranslationClient {
        if let existing = application.storage[GoogleCloudTranslationKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.GoogleCloudPlatform.GoogleCloudTranslationAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[GoogleCloudTranslationKey.self] = new
            return new
        }
    }
}
