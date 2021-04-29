//
//  GoogleCloudSecretManagerAPI.swift
//  
//
//  Created by Andrew Edwards on 4/29/21.
//

import Vapor
@_exported import SecretManager
@_exported import GoogleCloud

extension Application.GoogleCloudPlatform {
    
    private struct CloudSecretManagerAPIKey: StorageKey {
        typealias Value = GoogleCloudSecretManagerAPI
    }
    
    private struct CloudSecretManagerConfigurationKey: StorageKey {
        typealias Value = GoogleCloudSecretManagerConfiguration
    }
    
    private struct CloudSecretManagerHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    public var secretManager: GoogleCloudSecretManagerAPI {
        get {
            if let existing = self.application.storage[CloudSecretManagerAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudSecretManagerAPIKey.self] = newValue
        }
    }
    
    public struct GoogleCloudSecretManagerAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `GoogleCloudSecretManager` API.
        public var client: GoogleCloudSecretManagerClient {
            do {
                let new = try GoogleCloudSecretManagerClient(credentials: self.application.googleCloud.credentials,
                                                       config: self.configuration,
                                                       httpClient: self.http,
                                                       eventLoop: self.eventLoop)
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `GoogleCloudSecretManager` APIs.
        public var configuration: GoogleCloudSecretManagerConfiguration {
            get {
                if let configuration = application.storage[CloudSecretManagerConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud SecretManager configuration has not been set. Use app.googleCloud.secretManager.configuration = ...")
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
            if let existing = application.storage[CloudSecretManagerHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudSecretManagerHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudSecretManagerHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudSecretManagerHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct GoogleCloudSecretManagerKey: StorageKey {
        typealias Value = GoogleCloudSecretManagerClient
    }
    
    /// A client used to interact with the `GoogleCloudSecretManager` API
    public var gcSecretManager: GoogleCloudSecretManagerClient {
        if let existing = application.storage[GoogleCloudSecretManagerKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.GoogleCloudPlatform.GoogleCloudSecretManagerAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[GoogleCloudSecretManagerKey.self] = new
            return new
        }
    }
}
