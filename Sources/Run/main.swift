//
//  File.swift
//  
//
//  Created by Andrew Edwards on 12/23/19.
//

import CloudStorage
import Vapor

do {
    let app = try Application(.detect())
    app.googleCloud.credentials = try GoogleCloudCredentialsConfiguration()
    app.googleCloud.storage.configuration = .default()
    
    app.get("") { req -> EventLoopFuture<String> in
        let gcs = req.gcs
        return gcs.buckets.delete(bucket: "hello-vapor")
            .flatMap { _ in
                return gcs
                    .buckets
                    .insert(name: "hello-vapor")
                    .map { bucket in
                    return bucket.selfLink ?? "Unknown"
                }
        }
    }
    
    try app.run()
} catch {
    print("\(error)")
}
